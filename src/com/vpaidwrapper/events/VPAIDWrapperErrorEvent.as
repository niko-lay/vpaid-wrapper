package com.vpaidwrapper.events {

import flash.events.Event;

public class VPAIDWrapperErrorEvent extends Event {
  public static const LOAD_ERROR:String = "VPAIDWrapperErrorEvent.LOAD_ERROR";
  private var _data:Object;

  public function VPAIDWrapperErrorEvent(pType:String, pData:Object = null) {
    super(pType, true, false);
    _data = pData;
  }

  public function get data():Object {
    return _data;
  }
}

}