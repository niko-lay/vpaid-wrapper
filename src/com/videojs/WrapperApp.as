package com.videojs {

import com.videojs.vpaid.AdUnit;

import flash.display.Sprite;

import com.videojs.vpaid.AdContainer;
import com.videojs.events.VideoJSEvent;

import flash.external.ExternalInterface;
import flash.utils.setTimeout;

import com.videojs.util.console;

public class WrapperApp extends Sprite {

  private var _uiView:WrapperView;

  public function init(adSrc:String, width:int, height:int):void {
    // Initialize main view
    _uiView = new WrapperView(width, height);
    addChild(_uiView);
    // Initialize ad sub-view
    var adUnits:Array = [];
    var adUnit:AdUnit = new AdUnit(adSrc, width, height, 30);
    adUnits.push(adUnit);
    _uiView.adView.init(adUnits);
  }
}

}