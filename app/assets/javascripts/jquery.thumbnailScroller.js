/*
Thumbnail scroller jQuery plugin
Author: malihu [http://manos.malihu.gr]
Homepage: manos.malihu.gr/jquery-thumbnail-scroller
*/
(function($){  
 $.fn.thumbnailScroller=function(options){  
	var defaults={ //default options
		scrollerType:"hoverPrecise", //values: "hoverPrecise", "hoverAccelerate", "clickButtons"
		scrollerOrientation:"horizontal", //values: "horizontal", "vertical"
		scrollEasing:"easeOutCirc", //easing type
		scrollEasingAmount:800, //value: milliseconds
		acceleration:2, //value: integer
		scrollSpeed:600, //value: milliseconds
		noScrollCenterSpace:0, //value: pixels
		autoScrolling:0, //value: integer
		autoScrollingSpeed:8000, //value: milliseconds
		autoScrollingEasing:"easeInOutQuad", //easing type
		autoScrollingDelay:2500 //value: milliseconds
	};
	var options=$.extend(defaults,options);
    return this.each(function(){ 
		//cache vars
		var $this=$(this);
		var $scrollerContainer=$this.children(".jTscrollerContainer");
		var $scroller=$this.children(".jTscrollerContainer").children(".jTscroller");
		var $scrollerNextButton=$this.children(".jTscrollerNextButton");
		var $scrollerPrevButton=$this.children(".jTscrollerPrevButton");
		//set scroller width
		if(options.scrollerOrientation=="horizontal"){
			$scrollerContainer.css("width",999999); 
			var totalWidth=$scroller.outerWidth(true);
			$scrollerContainer.css("width",totalWidth);
		}else{
			var totalWidth=$scroller.outerWidth(true);
		}
		var totalHeight=$scroller.outerHeight(true); //scroller height
		//do the scrolling
		if(totalWidth>$this.width() || totalHeight>$this.height()){ //needs scrolling		
			var pos;
			var mouseCoords;
			var mouseCoordsY;
			if(options.scrollerType=="hoverAccelerate"){ //type hoverAccelerate
				var animTimer;
				var interval=8;
				$this.hover(function(){ //mouse over
					$this.mousemove(function(e){
						pos=findPos(this);
						mouseCoords=(e.pageX-pos[1]);
						mouseCoordsY=(e.pageY-pos[0]);
					});
					clearInterval(animTimer);
					animTimer = setInterval(Scrolling,interval);
				},function(){  //mouse out
					clearInterval(animTimer);
					$scroller.stop();
				});
				$scrollerPrevButton.add($scrollerNextButton).hide(); //hide buttons
			}else if(options.scrollerType=="clickButtons"){
				ClickScrolling();
			}else{ //type hoverPrecise
				pos=findPos(this);
				$this.mousemove(function(e){
					mouseCoords=(e.pageX-pos[1]);
					mouseCoordsY=(e.pageY-pos[0]);
					var mousePercentX=mouseCoords/$this.width(); if(mousePercentX>1){mousePercentX=1;}
					var mousePercentY=mouseCoordsY/$this.height(); if(mousePercentY>1){mousePercentY=1;}
					var destX=Math.round(-((totalWidth-$this.width())*(mousePercentX)));
					var destY=Math.round(-((totalHeight-$this.height())*(mousePercentY)));
					$scroller.stop(true,false).animate({left:destX,top:destY},options.scrollEasingAmount,options.scrollEasing); 
				});
				$scrollerPrevButton.add($scrollerNextButton).hide(); //hide buttons
			}
			//auto scrolling
			if(options.autoScrolling>0){
				AutoScrolling();
			}
		} else {
			//no scrolling needed
			$scrollerPrevButton.add($scrollerNextButton).hide(); //hide buttons
		}
		//"hoverAccelerate" scrolling fn
		var scrollerPos;
		var scrollerPosY;
		function Scrolling(){
			if((mouseCoords<$this.width()/2) && ($scroller.position().left>=0)){
				$scroller.stop(true,true).css("left",0); 
			}else if((mouseCoords>$this.width()/2) && ($scroller.position().left<=-(totalWidth-$this.width()))){
				$scroller.stop(true,true).css("left",-(totalWidth-$this.width())); 
			}else{
				if((mouseCoords<=($this.width()/2)-options.noScrollCenterSpace) || (mouseCoords>=($this.width()/2)+options.noScrollCenterSpace)){
					scrollerPos=Math.round(Math.cos((mouseCoords/$this.width())*Math.PI)*(interval+options.acceleration));
					$scroller.stop(true,true).animate({left:"+="+scrollerPos},interval,"linear"); 
				}else{
					$scroller.stop(true,true);
				}
			}
			if((mouseCoordsY<$this.height()/2) && ($scroller.position().top>=0)){
				$scroller.stop(true,true).css("top",0); 
			}else if((mouseCoordsY>$this.height()/2) && ($scroller.position().top<=-(totalHeight-$this.height()))){
				$scroller.stop(true,true).css("top",-(totalHeight-$this.height())); 
			}else{
				if((mouseCoordsY<=($this.height()/2)-options.noScrollCenterSpace) || (mouseCoordsY>=($this.height()/2)+options.noScrollCenterSpace)){
					scrollerPosY=Math.cos((mouseCoordsY/$this.height())*Math.PI)*(interval+options.acceleration);
					$scroller.stop(true,true).animate({top:"+="+scrollerPosY},interval,"linear"); 
				}else{
					$scroller.stop(true,true);
				}
			}
		}
		//auto scrolling fn
		var autoScrollingCount=0;
		function AutoScrolling(){
			$scroller.delay(options.autoScrollingDelay).animate({left:-(totalWidth-$this.width()),top:-(totalHeight-$this.height())},options.autoScrollingSpeed,options.autoScrollingEasing,function(){
				$scroller.animate({left:0,top:0},options.autoScrollingSpeed,options.autoScrollingEasing,function(){
					autoScrollingCount++;
					if(options.autoScrolling>1 && options.autoScrolling!=autoScrollingCount){
						AutoScrolling();
					}
				});
			});
		}
		//click scrolling fn
		function ClickScrolling(){
			$scrollerPrevButton.hide();
			$scrollerNextButton.show();
			$scrollerNextButton.click(function(e){ //next button
				e.preventDefault();
				var posX=$scroller.position().left;
				var diffX=totalWidth+(posX-$this.width());
				var posY=$scroller.position().top;
				var diffY=totalHeight+(posY-$this.height());
				$scrollerPrevButton.stop().show("fast");
				if(options.scrollerOrientation=="horizontal"){
					if(diffX>=$this.width()){
						$scroller.stop().animate({left:"-="+$this.width()},options.scrollSpeed,options.scrollEasing,function(){
							if(diffX==$this.width()){
								$scrollerNextButton.stop().hide("fast");
							}
						});
					} else {
						$scrollerNextButton.stop().hide("fast");
						$scroller.stop().animate({left:$this.width()-totalWidth},options.scrollSpeed,options.scrollEasing);
					}
				}else{
					if(diffY>=$this.height()){
						$scroller.stop().animate({top:"-="+$this.height()},options.scrollSpeed,options.scrollEasing,function(){
							if(diffY==$this.height()){
								$scrollerNextButton.stop().hide("fast");
							}
						});
					} else {
						$scrollerNextButton.stop().hide("fast");
						$scroller.stop().animate({top:$this.height()-totalHeight},options.scrollSpeed,options.scrollEasing);
					}
				}
			});
			$scrollerPrevButton.click(function(e){ //previous button
				e.preventDefault();
				var posX=$scroller.position().left;
				var diffX=totalWidth+(posX-$this.width());
				var posY=$scroller.position().top;
				var diffY=totalHeight+(posY-$this.height());
				$scrollerNextButton.stop().show("fast");
				if(options.scrollerOrientation=="horizontal"){
					if(posX+$this.width()<=0){
						$scroller.stop().animate({left:"+="+$this.width()},options.scrollSpeed,options.scrollEasing,function(){
							if(posX+$this.width()==0){
								$scrollerPrevButton.stop().hide("fast");
							}
						});
					} else {
						$scrollerPrevButton.stop().hide("fast");
						$scroller.stop().animate({left:0},options.scrollSpeed,options.scrollEasing);
					}
				}else{
					if(posY+$this.height()<=0){
						$scroller.stop().animate({top:"+="+$this.height()},options.scrollSpeed,options.scrollEasing,function(){
							if(posY+$this.height()==0){
								$scrollerPrevButton.stop().hide("fast");
							}
						});
					} else {
						$scrollerPrevButton.stop().hide("fast");
						$scroller.stop().animate({top:0},options.scrollSpeed,options.scrollEasing);
					}
				}
			});
		}
	});  
 };  
})(jQuery); 
//global js functions
//find element Position
function findPos(obj){
	var curleft=curtop=0;
	if (obj.offsetParent){
		curleft=obj.offsetLeft
		curtop=obj.offsetTop
		while(obj=obj.offsetParent){
			curleft+=obj.offsetLeft
			curtop+=obj.offsetTop
		}
	}
	return [curtop,curleft];
}