package com.videojs.events {

import flash.events.Event;

public class VPAIDEvent extends Event {

  private var _data:Object;

  public function get data():Object {
    return this._data;
  }

  public function VPAIDEvent(param1:String, param2:Object = null, param3:Boolean = false, param4:Boolean = false) {
    super(param1, param3, param4);
    this._data = param2;
  }

  public static const AdLoaded:String = "AdLoaded";
  public static const AdStarted:String = "AdStarted";
  public static const AdStopped:String = "AdStopped";
  public static const AdError:String = "AdError";
  public static const AdVideoComplete:String = "AdVideoComplete";
  public static const AdImpression:String = "AdImpression";

  public static const AdPluginEventStart:String = "adstarted";
  public static const AdPluginEventImpression:String = "adimpression";
  public static const AdPluginEventTimeRemaining:String = "adtimeremaining";
  public static const AdPluginEventCanSkip:String = "adcanbeskipped";
}

}