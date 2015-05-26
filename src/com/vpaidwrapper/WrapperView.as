package com.vpaidwrapper {

import com.vpaidwrapper.events.*;
import com.vpaidwrapper.events.VPAIDWrapperEvent;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.media.Video;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import com.vpaidwrapper.vpaid.AdContainer;
import com.vpaidwrapper.events.VPAIDEvent;

import mx.formatters.NumberBase;

public class WrapperView extends Sprite {

  private var _model:AdContainer;
  private var _adView:*;
  private var _stageWidth:int;
  private var _stageHeight:int;

  /**
   * Constructor.
   * @param width
   * @param height
   */
  public function WrapperView(width:int, height:int) {
    _stageWidth = width;
    _stageHeight = height;
    // Listen to pertinent model events
    _model = AdContainer.getInstance();
    _model.addEventListener(VPAIDWrapperEvent.AD_LOADED, onAdLoaded);
    _model.addEventListener(VPAIDWrapperEvent.STAGE_RESIZE, onStageResize);
  }

  /**
   * Resize current ad view to the specified width and height.
   * @param width
   * @param height
   */
  private function resizeAdView(availableWidth:int, availableHeight:int):void {
    if (_adView != null) {
      var nativeWidth:int = _adView.content.width;
      var nativeHeight:int = _adView.content.height;
      // First, size the whole thing down based on the available width
      var targetWidth:int = availableWidth;
      var targetHeight:int = targetWidth * (nativeHeight / nativeWidth);
      // Calculate target dimensions
      if (targetHeight > availableHeight) {
        targetWidth = targetWidth * (availableHeight / targetHeight);
        targetHeight = availableHeight;
      }
      // Set sprites new dimensions
      _adView.width = targetWidth;
      _adView.height = targetHeight;
      // Update coordinates
      _adView.x = Math.round((availableWidth - _adView.width) / 2);
      _adView.y = Math.round((availableHeight - _adView.height) / 2);
    }
  }

  /**
   * Once an ad unit is loaded, we add it to the main view.
   * @param adContainer
   */
  private function onAdLoaded(e:VPAIDWrapperEvent):void {
    _adView = _model.displayObject;
    _adView.x = 0;
    _adView.y = 0;
    addChild(_adView);
  }

  /**
   * Fired when main stage is resized.
   * @param e
   */
  private function onStageResize(e:VPAIDWrapperEvent):void {
    _stageWidth = e.data.width;
    _stageHeight = e.data.height;
    resizeAdView(_stageWidth, _stageHeight);
  }
}

}