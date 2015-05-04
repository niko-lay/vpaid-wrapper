package com.videojs.util {
  import flash.external.ExternalInterface;

  public class console {
    public static function log(message:String):void {
      ExternalInterface.call('console.log', message);
    }
  }
}