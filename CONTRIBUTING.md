#Your first column
Making columns for Tabbie is extremely easy, and fun!  
This guide will show you how to make a basic column that gets some data from a 
I assume you have at least a little bit of understanding of polymer and coffeescript, and of course, frontend development in general.  
This guide is still WIP and a more in-depth, 'real' documentation page is planned.

##Step 1: Setting up your development environment.

1. Fork the project by clicking on fork at the right top.
2. Clone your url (`git clone https://github.com/yourusername/tabbie tabbie; cd tabbie`)
3. Make sure you've installed [node](http://nodejs.org)
4.
```
sudo npm install -g gulp bower #ignore if you already have gulp & bower installed
npm install
bower install
gulp watch
```
Tabbie will now open and you can start hacking :)

**NOTE**: because of the access-control exceptions not working when running tabbie from a web server, you're going to need to install (and enable) [this additional extension](https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi) to allow cross control domain accesss or else **some functionality of tabbie may not work.**

##Step 2: File structure
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
  
Start by renaming all files to your column (Reddit.coffee > Myservice.coffee), etc.

##Step 3: Column image
A column image exists of a 150x150 png in the src/img directory.
Column image can be defined with the 'thumb' property within a column's class. (more on that below)  
Files should be in column-\*.png.
Column images have a background that comes from [the google design color palette](www.google.com/design/spec/style/color.html#color-color-palette).
It is very important that column images have a background on them, as tabbie automatically looks for the most dominant color, and uses it for the rest of a column's 'toolbar'.
The logo itself on the column image must be white (#FFFFF), and a width of 75% of the total image, centered within the image itself.
Preferabely vector (check out [font-awesome](http://fontawesome.io), or google's [material icons](https://google.github.io/material-design-icons/))  
  
##Step 4: Get coding  
At this point I mostly assume you've got enough to get going, the existing columns are perfect examples of what is possible and how things need to be defined, I'll try to get into some more detail on everything down here below, but really, the existing columns are perfect examples which you can just modify to suit your needs.
  
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

  
Properties you can override:
  
**name**  _required_  :  Your column's display name.  
**width**: The width of your column (1 = 1 * 25% of the screen)  
**thumb** _required_: The filename of your column's image in src/img  
**element** _required_: The element name of the item you defined in _columnname_-item.html  
**dialog**: The element name of your configuration dialog in _columnname_-dialog.html  
**dataPath**: The 'path' of your data, if the server doesn't return a array as response, you'll need to use this. For example if your data is formatted like `{ data: { items: [] } }`, then your data path will be 'data.items'  
**childPath**: Same as dataPath, if the items in your array are not the 'root' of your item, use childPath.   
**dataType**: defaults to 'json', if your source is a RSS feed, use 'xml' here.  
**config**: Contains user's configuration, configured trough the dialog.  
**cache**: Contains cache, which has an array of previously loaded items.
  
Functions you can override:   

**refresh** (columnElement, holderElement): Called when refreshing is needed. columnElement is a reference to the column element defined in 'element'. holderElement is the holder in which items will need to be added.  
**draw** (data, holderElement): This is where FeedColumn appends children to the holder, data is an array holding each item, holderElement is the element where items need to be appended to.  
  
##Step 5: Your elements  
- The **dialog** element has a single variable called 'config'. You can add controls that use the the config's values as value (for example ``<input type='text' value='{{config.username}}>`)  
You can then use the config values from your column's class.  
- Same as the dialog element, the **item** element has a single variable, this time called 'item', item contains the array's item bound to this specific item in the list.

##Step 6: Pull request  
When you're satisfied with your work, you can file a pull request to the main tabbie repo, this is needed for your column to appear in the official extension.  
You can send us a pull request straight from github itself, [just hit the 'compare & review' button on your repo's page.](https://help.github.com/articles/using-pull-requests/)  
We will then review your work, and if it's all good, it'll get added, yay!