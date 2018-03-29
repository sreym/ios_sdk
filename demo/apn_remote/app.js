var apn = require('apn');
var auth = require('./auth.js');

var notification = new apn.Notification();
notification.topic = 'org.hola.hola-spark-demo2';
notification.category = 'spark-preview';
notification.expiry = Math.floor(Date.now() / 1000) + 3600;
notification.sound = 'ping.aiff';
notification.alert = {title: 'Watch', body: 'Bucks bunny revenge movie'};
notification.mutableContent = true;
notification.payload = {
    'spark-customer-id': 'demo',
    'spark-media-url':
        'https://video.h-cdn.com/static/mp4/bbb_sunflower_360p_30fps.mp4',
};

var provider = new apn.Provider({token: auth.token, production: false});
provider.send(notification, auth.devices).then(function(result) {
    console.log(result);
});
