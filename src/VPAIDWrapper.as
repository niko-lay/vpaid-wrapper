package {

import com.videojs.WrapperApp;
import com.videojs.events.VideoJSEvent;
import com.videojs.structs.ExternalEventName;
import com.videojs.structs.ExternalErrorEventName;
import com.videojs.Base64;
import com.videojs.util.console;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.external.ExternalInterface;
import flash.geom.Rectangle;
import flash.system.Security;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.setTimeout;

[SWF(backgroundColor="#000000", frameRate="60", width="480", height="270")]
public class VPAIDWrapper extends Sprite {

  public const VERSION:String = CONFIG::version;

  private var _app:WrapperApp;
  private var _stageSizeTimer:Timer;

  public function VPAIDWrapper() {
    _stageSizeTimer = new Timer(250);
    _stageSizeTimer.addEventListener(TimerEvent.TIMER, onStageSizeTimerTick);
    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
  }

  private function init():void {
    // Allow JS calls from other domains
    Security.allowDomain("*");
    Security.allowInsecureDomain("*");
    setUpContextMenu();
    console.log('VPAIDWrapper::init - initializing with ad source:', loaderInfo.parameters.src);

    if (loaderInfo.hasOwnProperty("uncaughtErrorEvents")) {
      // we'll want to suppress ANY uncaught debug errors in production (for the sake of ux)
      // IEventDispatcher(loaderInfo["uncaughtErrorEvents"]).addEventListener("uncaughtError", onUncaughtError);
    }

    if (ExternalInterface.available) {
      registerExternalMethods();
    }

    _app = new WrapperApp();
    addChild(_app);
    _app.init(loaderInfo.parameters.src, stage.stageWidth, stage.stageHeight);
  }

  private function setUpContextMenu():void {
    var _ctxVersion:ContextMenuItem = new ContextMenuItem("VPAID Wrapper v" + VERSION, false, false);
    var _ctxAbout:ContextMenuItem = new ContextMenuItem("Copyright © 2015 JP Ventures, LTD.", false, false);
    var _ctxMenu:ContextMenu = new ContextMenu();
    _ctxMenu.hideBuiltInItems();
    _ctxMenu.customItems.push(_ctxVersion, _ctxAbout);
    this.contextMenu = _ctxMenu;
  }

  private function registerExternalMethods():void {

    try {
      ExternalInterface.addCallback("vwEcho", onEchoCalled);
      ExternalInterface.addCallback("vwGetProperty", onGetPropertyCalled);
      ExternalInterface.addCallback("vwSetProperty", onSetPropertyCalled);
    }
    catch (e:SecurityError) {
      if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
        throw new SecurityError(e.message);
      }
    }
    catch (e:Error) {
      if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
        throw new Error(e.message);
      }
    }
    finally {
    }
    setTimeout(finish, 50);
  }

  private function finish():void {

    if (loaderInfo.parameters.src != undefined && loaderInfo.parameters.src != "") {
      // _app.model.srcFromFlashvars = String(loaderInfo.parameters.src);
    }

    if (loaderInfo.parameters.readyFunction != undefined) {
      try {
        //ExternalInterface.call(_app.model.cleanEIString(loaderInfo.parameters.readyFunction), ExternalInterface.objectID);
        console.log('zomg');
      }
      catch (e:Error) {
        if (loaderInfo.parameters.debug != undefined && loaderInfo.parameters.debug == "true") {
          throw new Error(e.message);
        }
      }
    }

    //_app.model.broadcastEvent(new VideoJSEvent(VideoJSEvent.INIT_DONE, {}));
  }

  private function onAddedToStage(e:Event):void {
    stage.addEventListener(MouseEvent.CLICK, onStageClick);
    stage.addEventListener(Event.RESIZE, onStageResize);
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;
    _stageSizeTimer.start();
  }

  private function onStageSizeTimerTick(e:TimerEvent):void {
    if (stage.stageWidth > 0 && stage.stageHeight > 0) {
      _stageSizeTimer.stop();
      _stageSizeTimer.removeEventListener(TimerEvent.TIMER, onStageSizeTimerTick);
      init();
    }
  }

  private function onStageResize(e:Event):void {
    if (_app != null) {
      //_app.model.stageRect = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
      //_app.model.broadcastEvent(new VideoJSEvent(VideoJSEvent.STAGE_RESIZE, {}));
    }
  }

  private function onEchoCalled(pResponse:* = null):* {
    return pResponse;
  }

  private function onGetPropertyCalled(pPropertyName:String = ""):* {
    switch (pPropertyName) {
      case "mode":
        break;
      //return _app.model.mode;
    }
    return null;
  }

  private function onSetPropertyCalled(pPropertyName:String = "", pValue:* = null):void {
    switch (pPropertyName) {
      case "duration":
        //_app.model.duration = Number(pValue);
        break;
      default:
        //_app.model.broadcastErrorEventExternally(ExternalErrorEventName.PROPERTY_NOT_FOUND, pPropertyName);
        break;
    }
  }

  private function onUncaughtError(e:Event):void {
    e.preventDefault();
  }

  private function onStageClick(e:MouseEvent):void {
    //_app.model.broadcastEventExternally(ExternalEventName.ON_STAGE_CLICK);
  }
}

}
