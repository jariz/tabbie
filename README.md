#Tabbie
Still in development.

##Contributing to Tabbie
Want to add your favorite website? Want to add a awesome column that has nothing to do with websites? You can!  
It is extremely simple to contribute to Tabbie! You won't even need to install the extension.

1. Fork the project by clicking on fork at the right top.
2. Clone your url (`git clone https://github.com/yourusername/tabbie tabbie; cd tabbie`)
3. Make sure you've installed [node](http://nodejs.org)
4. 
```
sudo npm install -g gulp bower #ignore if you already have gulp & bower installed
npm install
bower install
gulp serve
```
Tabbie will now open and you can start hacking :)  

**NOTE**: because of the access-control exceptions not working when running tabbie from a web server, you're going to need to install (and enable) [this additional extension](https://chrome.google.com/webstore/detail/allow-control-allow-origi/nlfbmbojpeacfghkpbjhddihlkkiljbi) to allow cross control domain accesss or else **some functionality of tabbie may not work.**
