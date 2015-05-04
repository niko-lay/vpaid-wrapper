package com.videojs {
    
    import flash.display.Sprite;
    import com.videojs.vpaid.AdContainer;
    import com.videojs.util.CreativeSourceLoader;
    import com.videojs.events.VideoJSEvent;
    import flash.external.ExternalInterface;
    import flash.utils.setTimeout;
    import com.videojs.util.console;
    
    public class VideoJSApp extends Sprite{
        
        private var _uiView:VideoJSView;
        private var _model:VideoJSModel;
        private var _adSrc:String;
        
        public function VideoJSApp(adSrc){
            //_model = VideoJSModel.getInstance();
            _adSrc = adSrc;

        }
        
        public function init():void {
            console.log('ZOMG CONSOLE.LOG!');
            _uiView = new VideoJSView();
            addChild(_uiView);
            var adSource: Array = [];
            adSource.push({
                path: _adSrc,
                height: 460,
                width: 640,
                type: 'application/x-shockwave-flash',
                duration: 30,
                creativeSource: ''
            });
            _uiView.adView.init(adSource);
            _uiView.adView.loadAdAsset()
        }

        public function get model():VideoJSModel{
            return _model;
        }
    }
}