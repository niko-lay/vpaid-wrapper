package com.vpaidwrapper.util {
  import flash.external.ExternalInterface;

  public class console {
    public static function log(message:String, ... args):void {
      if (args[0] == null) {
        ExternalInterface.call('console.log', message);
      } else {
        ExternalInterface.call('console.log', message, args[0]);
      }
    }
  }
}