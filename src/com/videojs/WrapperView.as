package com.videojs {

import com.videojs.events.*;

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

import com.videojs.vpaid.AdContainer;
import com.videojs.events.VPAIDEvent;

import mx.formatters.NumberBase;

public class WrapperView extends Sprite {

  private var _adView:AdContainer;
  private var _stageWidth:int;
  private var _stageHeight:int;


  public function WrapperView(width:int, height:int) {
    _stageWidth = width;
    _stageHeight = height;

    //_model = VideoJSModel.getInstance();
    //_model.addEventListener(VideoJSEvent.POSTER_SET, onPosterSet);
    //_model.addEventListener(VideoJSEvent.BACKGROUND_COLOR_SET, onBackgroundColorSet);
    //_model.addEventListener(VideoJSEvent.STAGE_RESIZE, onStageResize);
    //_model.addEventListener(VideoPlaybackEvent.ON_STREAM_START, onStreamStart);
    //_model.addEventListener(VideoPlaybackEvent.ON_META_DATA, onMetaData);
    //_model.addEventListener(VideoPlaybackEvent.ON_VIDEO_DIMENSION_UPDATE, onDimensionUpdate);

    // Draw ad view
    _adView = new AdContainer();
    _adView.x = 0;
    _adView.y = 0;
    _adView.addEventListener(VPAIDEvent.AdLoaded, onAdStart);
    addChild(_adView);
  }

  public function get adView():AdContainer {
    return _adView;
  }

/*  private function onBackgroundColorSet(e:VideoPlaybackEvent):void {
    _uiBackground.graphics.clear();
    _uiBackground.graphics.beginFill(1, 1);
    _uiBackground.graphics.drawRect(0, 0, _stageWidth, _stageHeight);
    _uiBackground.graphics.endFill();
  }*/

  private function onStageResize(e:VideoJSEvent):void {
    _stageWidth = e.data.width;
    _stageHeight = e.data.height;
    //_uiBackground.graphics.clear();
    //_uiBackground.graphics.beginFill(1, 1);
    //_uiBackground.graphics.drawRect(0, 0, _stageWidth, _stageHeight);
    //_uiBackground.graphics.endFill();
    //sizePoster();
    //sizeVideoObject();
  }

  private function onAdStart(e:Object):void {
    //_uiPosterImage.visible = false;
  }


  //private function onDimensionUpdate(e:VideoPlaybackEvent):void {
    //sizeVideoObject();
  //}
}

}