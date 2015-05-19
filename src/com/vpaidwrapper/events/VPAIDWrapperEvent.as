package com.vpaidwrapper.events {

import flash.events.Event;

public class VPAIDWrapperEvent extends Event {
  public static const READY:String = "VPAIDWrapperEvent.READY";
  public static const AD_LOADED:String = "VPAIDWrapperEvent.AD_LOADED";
  public static const STAGE_RESIZE:String = "VPAIDWrapperEvent.STAGE_RESIZE";
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