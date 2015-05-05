package com.vpaidwrapper.vpaid {

  public class AdUnit {
    private var _src:String;
    private var _width:int;
    private var _height:int;
    private var _duration:Number;
    private var _bitrate:Number;
    private var _creativeSource:String;

    public function AdUnit(src:String, width:int, height:int, duration:Number=0, bitrate:Number=800, creativeSource:String='') {
      _src = src;
      _width = width;
      _height = height;
      _duration = duration;
      _bitrate = bitrate;
      _creativeSource = creativeSource;
    }

    public function get src():String {
      return _src;
    }

    public function get width():int {
      return _width;
    }

    public function get height():int {
      return _height;
    }

    public function get duration():Number {
      return _duration;
    }

    public function get bitrate():Number {
      return _bitrate;
    }

    public function get creativeSource():String {
      return _creativeSource;
    }
  }
}