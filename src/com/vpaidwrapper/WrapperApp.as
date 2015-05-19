package com.vpaidwrapper {

import flash.display.Sprite;
import flash.external.ExternalInterface;
import flash.utils.setTimeout;

import com.vpaidwrapper.vpaid.AdContainer;
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
  public function init(adSrc:String, stageWidth:int, stageHeight:int):void {
    // Initialize main view
    _uiView = new WrapperView(stageWidth, stageHeight);
    addChild(_uiView);
    // Initialize ad sub-view
    _model = AdContainer.getInstance();
    _model.loadAdUnit(adSrc);
  }

  /**
   * Model getter.
   */
  public function get model():AdContainer {
    return _model;
  }
}

}