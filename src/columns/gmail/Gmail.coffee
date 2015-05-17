`
    //util functions kindly stolen from https://github.com/ebidel/polymer-gmail/

    function getValueForHeaderField(headers, field) {
        for (var i = 0, header; header = headers[i]; ++i) {
            if (header.name == field || header.name == field.toLowerCase()) {
                return header.value;
            }
        }
        return null;
    }

    function fixUpMessages(resp) {
        var messages = resp.result.messages;

        for (var j = 0, m; m = messages[j]; ++j) {
            var headers = m.payload.headers;
            var keep = ['subject', 'snippet', 'id', 'threadId']
            message = {}
            keep.forEach(function(key) {
                message[key] = m[key]
            })

            // Example: Thu Sep 25 2014 14:43:18 GMT-0700 (PDT) -> Sept 25.
            var date = new Date(getValueForHeaderField(headers, 'Date'));
            message.date = date.toDateString().split(' ').slice(1, 3).join(' ');
            message.to = getValueForHeaderField(headers, 'To');
            message.subject = getValueForHeaderField(headers, 'Subject');

            var fromHeaders = getValueForHeaderField(headers, 'From');
            var fromHeaderMatches = fromHeaders.match(new RegExp(/"?(.*?)"?\s?<(.*)>/));

            message.from = {};

            // Use name if one was found. Otherwise, use email address.
            if (fromHeaderMatches) {
                // If no a name, use email address for displayName.
                message.from.name = fromHeaderMatches[1].length ? fromHeaderMatches[1] : fromHeaderMatches[2];
                message.from.email = fromHeaderMatches[2];
            } else {
                message.from.name = fromHeaders.split('@')[0];
                message.from.email = fromHeaders;
            }
            message.from.name = message.from.name.split('@')[0]; // Ensure email is split.

            message.unread = m.labelIds.indexOf("UNREAD") != -1;
            message.starred = m.labelIds.indexOf("STARRED") != -1;

            messages[j] = message
        }

        return messages;
    }
`

class Columns.Gmail extends Columns.Column
  name: "Gmail"
  thumb: "img/column-gmail.png"
  dialog: "gmail-dialog"
  link: "https://mail.google.com/"

  holderEl: undefined
  columnEl: undefined

  logOut: =>
    #clear content, show spinner
    @holderEl.innerHTML = ""
    @loading = true
    delete @config.user
    @cache = []
    tabbie.sync @

    chrome.identity.getAuthToken
      interactive: false
    , (token) =>
      if !chrome.runtime.lastError
        #step 1, remove token from local storage
        chrome.identity.removeCachedAuthToken
          token: token
        , =>
            #step 2, revoke token @ google
            fetch("https://accounts.google.com/o/oauth2/revoke?token=" + token)
              .catch =>
                #ok, so because we don't have permissions this we can't complete the request, but this doesn't matter, because the token is revoked eitherway.
                #wait 1 sec because else weird things start to happen (token not actually being revoked / getAuthToken returning a new token)
                setTimeout =>
                  @loading = false
                  @refresh @columnEl, @holderEl
                , 1000

  draw: (data, holderElement) =>
    @loading = false
    @refreshing = false

    holderElement.innerHTML = ""

    for item in data
      child = document.createElement "gmail-item"
      child.item = item
      holderElement.appendChild child

  render: (columnElement, holderElement) ->
    super columnElement, holderElement

    @columnEl = columnElement
    @holderEl = holderElement

    if Object.keys(@cache).length
      @draw @cache, holderElement
    @refresh columnElement, holderElement

  refresh: (columnElement, holderElement) ->
    if not @config.colors then @config.colors = {}
    
    @refreshing = true
    gapiEl = document.createElement "google-client-api"
    columnElement.appendChild gapiEl

    gapiEl.addEventListener "api-load", =>
      console.info 'gapi loaded'
      chrome.identity.getAuthToken
        interactive: false
      , (token) =>
          if !chrome.runtime.lastError
            gapi.auth.setToken
              access_token: token,
              duration: "52000",
              state: "https://www.googleapis.com/auth/gmail.modify"

            console.log "Auth token data", gapi.auth.getToken()

            gapi.client.load "gmail", "v1", =>
              if not @config.user
                gapi.client.load "plus", "v1", =>
                  console.info "gplus loaded"
                  batch = gapi.client.newBatch()
                  batch.add gapi.client.plus.people.get
                    userId: 'me'
                  batch.add gapi.client.gmail.users.getProfile
                    userId: 'me'
                  batch.then (resp) =>
                    @config.user = {}
                    @config.user[key] = value for key, value of item.result for k, item of resp.result
              console.info "user", @config.user
              console.info "gmail loaded"
              gmail = gapi.client.gmail.users
              gmail.threads.list
                userId: 'me',
                q: 'in:inbox'
              .then (resp) =>
                batch = gapi.client.newBatch()

                if not resp.result.threads
                  @draw [], holderElement
                  return

                resp.result.threads.forEach (thread) =>
                  req = gmail.threads.get
                    userId: 'me',
                    id: thread.id
                  batch.add req

                batch.then (resp) =>
                  messages = []
                  for key, item of resp.result
                    fixed = fixUpMessages item
                    #grab first, add amount of messages in thread to message
                    message = fixed[0]
                    message.amount = fixed.length
                    #check if we already generated a color for this recipient, if not, generate it & save it
                    if not @config.colors[message.from.email] then message.color = @config.colors[message.from.email] = Please.make_color()[0]
                    else message.color = @config.colors[message.from.email]
                    messages.push message
                  #batch returns threads in a random order, so resort them based on their hex id's
                  messages = messages.sort (a, b) ->
                    ax = parseInt a.id, 16
                    bx = parseInt b.id, 16

                    if ax > bx then return -1
                    else return 1
                  @cache = messages
                  tabbie.sync @
                  @draw messages, holderElement
          else
            @loading = false
            @refreshing = false
            auth = document.createElement "gmail-auth"
            auth.addEventListener "sign-in", =>
              @render columnElement, holderElement
            holderElement.innerHTML = ""
            holderElement.appendChild auth

tabbie.register "Gmail"