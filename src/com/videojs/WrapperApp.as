package com.videojs {

  import flash.display.Sprite;

  import com.videojs.vpaid.AdContainer;
  import com.videojs.util.CreativeSourceLoader;
  import com.videojs.events.VideoJSEvent;

  import flash.external.ExternalInterface;
  import flash.utils.setTimeout;

  import com.videojs.util.console;

  public class WrapperApp extends Sprite {

    private var _uiView:WrapperView;
    private var _model:VideoJSModel;

    public function WrapperApp() {

    }

    public function init(adSrc:String, width, height):void {
      console.log('ZOMG CONSOLE.LOG!');
      _uiView = new WrapperView(width, height);
      addChild(_uiView);
      var adSource:Array = [];
      adSource.push({
        path: adSrc,
        height: 460,
        width: 640,
        type: 'application/x-shockwave-flash',
        duration: 30,
        creativeSource: ''
      });
      _uiView.adView.init(adSource);
      _uiView.adView.loadAdAsset()
    }

    public function get model():VideoJSModel {
      return _model;
    }
  }

}