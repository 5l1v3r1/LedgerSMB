/** @format */

define([
   "dojo/_base/declare",
   "dojo/dom",
   "dojo/dom-style",
   "dojo/on",
   "dojo/topic",
   "dijit/_WidgetBase",
], function (declare, dom, style, on, topic, _WidgetBase) {
   return declare("lsmb/SubscribeShowHide", [_WidgetBase], {
      topic: "",
      showValues: null,
      hideValues: null,
      show: function () {
         style.set(this.domNode, "display", "block");
      },
      hide: function () {
         style.set(this.domNode, "display", "none");
      },
      update: function (targetValue) {
         if (this.showValues && this.showValues.indexOf(targetValue) !== -1) {
            this.show();
         } else if (
            this.hideValues &&
            this.hideValues.indexOf(targetValue) !== -1
         ) {
            this.hide();
         } else if (!this.showValues) {
            this.show();
         } else if (!this.hideValues) {
            this.hide();
         }
         // otherwise, do nothing
      },
      postCreate: function () {
         var self = this;
         this.inherited(arguments);

         this.own(
            topic.subscribe(self.topic, function (targetValue) {
               self.update(targetValue);
            })
         );
      },
   });
});
