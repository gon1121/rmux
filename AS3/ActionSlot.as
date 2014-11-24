/**************************************************************************

Filename    :   ActionSlot.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package 
{
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import scaleform.gfx.FocusEventEx;
    import scaleform.gfx.MouseEventEx;
    
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.DragEvent;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.events.DragEvent;
    import scaleform.clik.interfaces.IDragSlot;
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.managers.DragManager;
    
    public class ActionSlot extends UIComponent
    {
    // Constants:
    
    // Public Properties:
        
    // Protected Properties:
        /** The x-coordinate of the original MOUSE_DOWN event. Used to discern when the mouse has traveled enough to trigger a DragEvent. */
        protected var _mouseDownX:Number;
        /** The y-coordinate of the original MOUSE_DOWN event. Used to discern when the mouse has traveled enough to trigger a DragEvent. */
        protected var _mouseDownY:Number;
        /** Reference to the content Sprite that will be dragged about the Stage. */
        protected var _content:Sprite;
        /** Unique numeric value that represents the data held by this DragSlot. */
        protected var _data:Object; // NFM: Consider for removal here. Move into a subclass.
        protected var _stageRef:Stage = null;
        protected var _newFrame:String;
        protected var _stateMap:Object = {
            up:["up"],
            over:["over"],
            down:["down"],
            release: ["release", "over"],
            out:["out","up"],
            disabled:["disabled"],
            selecting: ["selecting", "over"]
        }
        protected var _state:String;
        
    // UI Elements:
        /** Reference to the canvas which the content Sprite will be attached to. */
        public var contentCanvas:Sprite;
        
    // Initialization:
        public function ActionSlot() {
            super();
            
            if (!contentCanvas) { 
                contentCanvas = new Sprite();
                addChild(contentCanvas);
            }
            
            trackAsMenu = true;
        }
        
    // Public Getter / Setters:
        /** 
         * Data related to the DragSlot. This may be include information about the slot itself or the content to be dragged.
         */
        public function get data():Object { return _data; }
        public function set data(value:Object):void {
            _data = value;
            invalidateData();
        }
        
        /** 
         * A reference to the Sprite or MovieClip that will be dragged from the DragSlot. This will generally be a Sprite containing a Bitmap.
         */
        public function get content():Sprite { return _content; }
        public function set content(value:Sprite):void {
            if (value != _content) {
                if (_content) {
                    // If we're still the parent of our old _content, removeChild it. Could be overriden by subclass.
                    if (contentCanvas.contains(_content)) { 
                        contentCanvas.removeChild(_content);
                    }
                }
                
                _content = value;
                if (_content == null) { return; }
                
                // Reparent the icon for the data at 0,0 on the contentCanvas.
                if (_content != this) { 
                    contentCanvas.addChild(_content); // NFM: This should come from the data Object. Maybe set data() creates a Sprite?
                    _content.x = 0; 
                    _content.y = 0;
                    _content.mouseChildren = false;
                }
            }
        }
    
    // Public Methods:
        /** Sets the DragSlot's stage reference, required for dragging functionality, in the case that the DragSlot does not exist on the stage already . */
        public function setStage(value:Stage):void {
            if (_stageRef == null && value != null) { 
                _stageRef = value;
            }
        }

    // Protected Methods:
        override protected function configUI():void {
            super.configUI();
            
            addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver, true, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            addEventListener(MouseEvent.ROLL_OVER, handleMouseRollOver, false, 0, true);
            addEventListener(MouseEvent.ROLL_OUT, handleMouseRollOut, false, 0, true);
        }
        
        override protected function draw():void {
            super.draw();
            if (isInvalid(InvalidationType.STATE)) {
                if (_newFrame) {
                    gotoAndPlay(_newFrame);
                    _newFrame = null;
                }
            }
        }
        
        /** @exclude */
        override public function toString():String { 
            return "[ActionSlot " + name + "]";
        }
        
        protected function handleMouseOver(e:MouseEvent):void {
        }
        
        protected function handleMouseDown(e:MouseEvent):void {
            if (_content != null) {
                stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false, 0, true);
                stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
            
                _mouseDownX = mouseX;
                _mouseDownY = mouseY;
            }
        }
        
        protected function handleMouseRollOver(event:MouseEvent):void {
            if (!enabled) { return; }
            setState("over");
        }
        
        protected function handleMouseRollOut(event:MouseEvent):void {
            if (!enabled) { return; }
            setState("out"); 
        }
        
        protected function cleanupDragListeners():void {
            // Clean up the original mouse listeners since we've started a DragEvent.
            stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp, false);
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false);
            
            _mouseDownX = undefined;
            _mouseDownY = undefined;
        }
        
        protected function handleMouseMove(e:MouseEvent):void {
            // NFM: This should be moved into a subclass.
            // Require the user to add at least 3 pixels of mouse movement to start an official drag.
            if (mouseX > _mouseDownX + 3 || mouseX < _mouseDownX - 3 || 
                mouseY > _mouseDownY + 3 || mouseY < _mouseDownY - 3) { 
                //cleanupDragListeners()
                
                // Dispatch the DragEvent to be caught by the DragManager.
                //var dragStartEvent:DragEvent = new DragEvent(DragEvent.DRAG_START, _data, this, null, _content)
                //dispatchEvent(dragStartEvent);
                //handleDragStartEvent(dragStartEvent);
            }
        }
        
        protected function handleMouseUp(e:MouseEvent):void { 
            // Clean up the original mouse listeners since the user has "clicked".
            //cleanupDragListeners()
            
            _content.x = 0;
            _content.y = 0;
            
            // Dispatch a generic CLIK ButtonEvent.CLICK to be caught by whomever may be listening.
            dispatchEvent(new ButtonEvent(ButtonEvent.CLICK));
        }
        
        public function handleDragStartEvent(e:DragEvent):void {
            // Base functionality will be to hide the _content. Could be gray-scaled. Can be subclassed.
        }
        
        public function handleDropEvent(e:DragEvent):Boolean {
            return false;
        }
        
        public function handleDragEndEvent(e:DragEvent, wasValidDrop:Boolean):void {
        }
        
        protected function setState(state:String):void {
            _state = state;
            var states:Array = _stateMap[state];
            if (states == null || states.length == 0) { return; }
            var sl:uint = states.length;
            for (var j:uint=0; j<sl; j++) {
                var thisLabel:String = states[j];
                if (_labelHash[thisLabel]) {
                    _newFrame = thisLabel;
                    invalidateState();
                    return;
                }
            }
        }
    }
}