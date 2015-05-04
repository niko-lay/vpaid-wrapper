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

  public function WrapperApp() {

  }

  public function init(adSrc:String, width:int, height:int):void {
    // Initialize main view
    _uiView = new WrapperView(width, height);
    addChild(_uiView);
    // Initialize ad sub-view
    var adAssets:Array = [];
    adAssets.push({
      path: adSrc,
      width: width,
      height: height,
      type: 'application/x-shockwave-flash',
      duration: 30,
      creativeSource: ''
    });
    _uiView.adView.init(adAssets);
    _uiView.adView.loadAdAsset()
  }
}

}