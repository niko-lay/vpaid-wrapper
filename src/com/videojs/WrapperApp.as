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

  /**
   * Initialized application by loading all views and the specified ad.
   * @param adSrc
   * @param stageWidth
   * @param stageHeight
   * @param adDuration
   * @param adBitrate
   */
  public function init(adSrc:String, stageWidth:int, stageHeight:int, adDuration:Number, adBitrate:Number):void {
    // Initialize main view
    _uiView = new WrapperView(stageWidth, stageHeight);
    addChild(_uiView);
    // Initialize ad sub-view
    var adUnits:Array = [];
    var adUnit:AdUnit = new AdUnit(adSrc, stageWidth, stageHeight, adDuration, adBitrate);
    adUnits.push(adUnit);
    _uiView.adView.init(adUnits);
  }
}

}