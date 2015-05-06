package com.vpaidwrapper.util {

import flash.external.ExternalInterface;

public class JSInterface {

  private static var _jsEventProxyName:String = "VPAIDWrapper.onEvent";
  private static var _jsErrorEventProxyName:String = "VPAIDWrapper.onError";

  /**
   * This is an internal proxy that allows instances in this swf to broadcast events to a JS proxy function, if one is defined.
   * @param args
   *
   */
  public static function broadcast(... args):void {
    if (ExternalInterface.available) {
      var __incomingArgs:* = args as Array;
      var __newArgs:Array = [_jsEventProxyName, ExternalInterface.objectID].concat(__incomingArgs);
      var __sanitizedArgs:Array = cleanObject(__newArgs);
      ExternalInterface.call.apply(null, __sanitizedArgs);
    }
  }

  /**
   * This is an internal proxy that allows instances in this swf to broadcast error events to a JS proxy function, if one is defined.
   * @param args
   *
   */
  public function broadcastError(... args):void {
    if (ExternalInterface.available) {
      var __incomingArgs:* = args as Array;
      var __newArgs:Array = [_jsErrorEventProxyName, ExternalInterface.objectID].concat(__incomingArgs);
      var __sanitizedArgs:Array = cleanObject(__newArgs);
      ExternalInterface.call.apply(null, __sanitizedArgs);
    }
  }

  /**
   * Removes dangerous characters from a user-provided string that will be passed to ExternalInterface.call()
   * @param pString
   * @return
   */
  public static function cleanEIString(pString:String):String{
    return pString.replace(/[^A-Za-z0-9_.]/gi, "");
  }

  /**
   * Recursive function to sanitize an object (or array) before passing to ExternalInterface.call()
   * @param obj
   * @return
   */
  private static function cleanObject(obj:*):*{
    if (obj is String) {
      return obj.split("\\").join("\\\\");
    } else if (obj is Array) {
      var __sanitizedArray:Array = new Array();
      for each (var __item in obj){
        __sanitizedArray.push(cleanObject(__item));
      }
      return __sanitizedArray;
    } else if (typeof(obj) == 'object') {
      var __sanitizedObject:Object = new Object();
      for (var __i in obj){
        __sanitizedObject[__i] = cleanObject(obj[__i]);
      }
      return __sanitizedObject;
    } else {
      return obj;
    }
  }

}

}