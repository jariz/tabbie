# Your first column
Making columns for Tabbie is extremely easy, and fun!  
This guide will show you how to make a basic column that gets some data from a external source (like pratically any column)  
We won't care if your column is not in that format. A column doesn't necessarily need to be in the above said format, but for the sake of simplicity we'll use FeedColumn in this guide. You are free to extend from Column as well, however, that won't be explained here.   
Feeds can be from a JSON or a RSS source.  
I assume you have at least a little bit of understanding of polymer and coffeescript, and of course, frontend development in general.  
This guide is still WIP and a more in-depth, 'real' documentation page is planned.

## Step 1: Setting up your development environment.

- Make sure you've installed 
  - [node](http://nodejs.org)
  - [Ruby](https://www.ruby-lang.org) (or use [rvm](https://rvm.io/))
  - [Git](http://git-scm.org)
- Fork the project by clicking on fork at the right top.
- Clone your fork to your local machine.  
```bash
git clone https://github.com/yourusername/tabbie
cd tabbie
```


- Run the following (in your working directory)
```bash
# ignore this command if you already have gulp & bower installed. Remove 'sudo' from the beginning if on windows
sudo npm install -g gulp bower  
# ignore if you already installed compass
gem install compass
npm install
bower install
gulp watch # every time you run this commands will overwrite the 'dist' folder with the new changed updates if there're, you can re-run this command several times to test your changes.
```
- **Load the extension into chrome**:  
A new folder called 'dist' has appeared in your working directory. Everything in src/ will be compiled to dist/. Do not touch dist as it's all compiled files.  
Load the dist folder into chrome by going to settings > extensions. Enable developer mode if you haven't already and choose 'Load unpacked extension...' and choose the dist folder.  

## Step 2: File structure
Start up by creating said files. It is easiest to copy a existing column and go from there.  
The average column looks like this:
```
|-- reddit
|
|--- Reddit.coffee
|--- reddit-item.html
---- reddit-dialog.html
```
- The coffee file, is the main class of the column, all column logic and settings happen here.
- The \*-item.html file which is used by FeedColumn (more on this below)  
- The \*-dialog.html has the contents of the configuration dialog. Optional.  
  
Start by renaming all files to your column (Reddit.coffee > Myservice.coffee, reddit-dialog.html > myservice-dialog.html), etc.  
Also rename the class file and the register call (`tabbie.register "Myservice"`) at the bottom of the class

## Step 3: Column image
A column image exists of a 150x150 png in the src/img directory.
Column image can be defined with the 'thumb' property within a column's class. (more on that below)  
Files should be in column-\*.png.
Column images have a background that comes from [the google design color palette](https://www.google.com/design/spec/style/color.html#color-color-palette).
It is very important that column images have a background on them, as tabbie automatically looks for the most dominant color, and uses it for the rest of a column's 'toolbar'.
The logo itself on the column image must be white (#FFFFF), and a width of 75% of the total image, centered within the image itself.
Preferably vector (check out [font-awesome](http://fontawesome.io), or google's [material icons](https://google.github.io/material-design-icons/))  
  
## Step 4: [Get coding](http://media.giphy.com/media/6OrCT1jVbonHG/giphy.gif)  
At this point I mostly assume you've got enough to get going, the existing columns are perfect examples of what is possible and how things need to be defined, I'll try to get into some more detail on everything down here below.
  
Here's an example of a column that uses all properties available (some are optional, see below)  
```coffee
class Columns.Lobsters extends Columns.FeedColumn
  name: "Lobste.rs"
  width: 1
  thumb: "column-lobsters.png"
  
  element: "lobsters-item"
  dialog: "lobsters-dialog"
  dataPath: "data.items"
  childPath: "data"

  refresh: (holderEl, columnEl) =>
    if not @config.listing then @config.listing = 0

    switch @config.listing
      when 0 then listing = "hottest"
      when 1 then listing = "newest"

    @url = "https://lobste.rs/"+listing+".json"
    super holderEl, columnEl

tabbie.register "Lobsters"
```
In this example we, as you can see, manipulate the 'url' property by overriding refresh. We change the url based on how what the configuration is (configured by the user trough the dialog).    
Note that overriding refresh is not necessary, but done here for demonstration purposes. If your url never changes, you won't have to override refresh.

  
Properties you can override:  
_Note_: Fields not marked as required are optional.
  
**name**  _required_  :  Your column's display name.  
**width**: The width of your column (1 = 1 * 25% of the screen)  
**thumb** _required_: The filename of your column's image in src/img  
**element** _required_: The element name of the item you defined in _columnname_-item.html  
**dialog**: The element name of your configuration dialog in _columnname_-dialog.html  
**dataPath**: The 'path' of your data, if the server doesn't return a array as response, you'll need to use this. For example if your server response is formatted like `{ data: { items: [] } }`, then your data path will be 'data.items'  
**childPath**: Same as dataPath, if the items in your array are not the 'root' of your item, use childPath.   
**dataType**: defaults to 'json', if your source is a RSS feed, use 'xml' here.  
**config**: Contains user's configuration, configured trough the dialog.  
**cache**: Contains cache, which has an array of previously loaded items.
  
Functions you can override:   

**refresh** (columnElement, holderElement): Called when refreshing is needed. columnElement is a reference to the column element defined in 'element'. holderElement is the holder in which items will need to be added.  
**draw** (data, holderElement): This is where FeedColumn appends children to the holder. data is an array with the server's response. holderElement is the element where items need to be appended to.


### Configuring your **columnName.coffee** for RSS - XML BASED - feeds
tabbie is configured by default to hadle JSON sources automatically, but you can tweak it to handle your xml based column with this little instructions:
- Make a permission-request over the browser, because some browsers disable downloading data over domains
- Modify fields to handle your XML source (Built-in, dont worry)
- Go to your columnName-item.coffee and start coding

first of all you have to make sure you are politely requesting the user to give you his permission over downloading this XML over his broswer by using this code:
```coffee
  attemptAdd: (successCallback) ->
    chrome.permissions.request
      origins: ['http://feeds.feedburner.com/'] ## put here your rss domain
    , (granted) =>
      if granted and typeof successCallback is 'function' then successCallback()

```
Make sure to put your own RSS domain, in this example the XML url is `http://feeds.feedburner.com/scientificamerican?fmt=xml` so the RSS domain is `http://feeds.feedburner.com/`.
**note**: post this requesting code below your fields section and over your `tabbie.register "columnName"` line, like so

```coffee
class Columns.columnName extends Columns.FeedColumn
  name: "Column Name"
  width: 1
  thumb: "img/column-columnName.png"
  link: "https://www.columnWebsite.com/"

  element: "columnName-item"
  url: "http://feeds.feedburner.com/scientificamerican?fmt=xml"    ## your xml url instead of .JSON one
  responseType: "xml"    ## it's dangerously important as it's our little magic tweak
  xmlTag: "item"    ## put here your parent tag which contains " The full post style ", more detailed below
 
  attemptAdd: (successCallback) ->
    chrome.permissions.request
      origins: ['http://feeds.feedburner.com/']
    , (granted) =>
      if granted and typeof successCallback is 'function' then successCallback()

tabbie.register "ScientificAmerican"
```
So, if your XML file was like this: 
```xml
<post>
<title>The Most Momentous Year in the History of Paleoanthropology</title>
<link>http://rss.sciam.com/~r/ScientificAmerican-News/~3/8Flz11GwMxs/</link>
<pubDate>Sat, 13 Jun 2015 00:01:00 GMT</pubDate>
<category>Evolutionary Biology</category>
<description>In an excerpt from his new book Ian Tattersall lays out the story of how a scientific giant in the field of evolution put forth a spectacularly incorrect theory about the diversity of hominids:F7zBnMyn0Lo</description>
</post>

```
Your **xmlTag** will be like that `xmlTag: "post"`

Now your finished with the columnName.coffe, go to your columnName-item.html and start coding, nothing changes when you want to the `<title>` tag in your `<h1></h1>` just write down - as usual - :
```html
<h1>{{item.title}}</h1>
```
and so on.

  
## Step 5: Your elements  
- The **-dialog** element has 2 variables, 'config' and 'column'.
You can add controls that use the the config's values as vlue (for example `<input type='text' value='{{config.username}}>`)
`column` is a reference to your column class (for example `Column name: <input type='text' value='{{column.name}}>`
- The **-item** element has a single variable, called 'item', item represents one of the values in the server's response.

## Step 6: Pull request  
When you're satisfied with your work, you can file a pull request to the main tabbie repo, this is needed for your column to appear in the official extension.  
You can send us a pull request straight from github itself, [just hit the 'compare & review' button on your repo's page.](https://help.github.com/articles/using-pull-requests/)  
We will then review your work, and if it's all good, it'll get added, yay!
