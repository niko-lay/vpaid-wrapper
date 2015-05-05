package com.vpaidwrapper.events {

import flash.events.Event;

public class VPAIDWrapperEvent extends Event {
  public static const INIT_DONE:String = "VideoJSEvent.INIT_DONE";
  public static const STAGE_RESIZE:String = "VideoJSEvent.STAGE_RESIZE";
  private var _data:Object;

  public function VPAIDWrapperEvent(pType:String, pData:Object = null) {
    super(pType, true, false);
    _data = pData;
  }

  public function get data():Object {
    return _data;
  }
}

}