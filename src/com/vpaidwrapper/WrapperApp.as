package com.vpaidwrapper {

import com.vpaidwrapper.vpaid.AdContainer;
import com.vpaidwrapper.vpaid.AdUnit;

import flash.display.Sprite;

import com.vpaidwrapper.vpaid.AdContainer;

import flash.external.ExternalInterface;
import flash.utils.setTimeout;

import com.vpaidwrapper.util.console;

public class WrapperApp extends Sprite {

  private var _uiView:WrapperView;
  private var _model:AdContainer;

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
    var adUnits:Array = [new AdUnit(adSrc, stageWidth, stageHeight, adDuration, adBitrate)];
    _model = new AdContainer();
    _model.init(adUnits);
    // Add to main view
    _uiView.adView = _model;
  }

  public function get model():AdContainer {
    return _model;
  }
}

}