define([
    'dojo/_base/declare',
    'dojo/_base/event',
    'dojo/dom-attr',
    'dijit/form/Button',
    'dojo/request/iframe',
    'dojo/dom-form'
],
       function(declare, event, domattr, Button, iframe, domform) {
           return declare('lsmb/PrintButton',
                          [Button],
               {
                   minimalGET: true,
                   onClick: function(evt) {
                       if (f.media.value == 'screen') {
                           var f = this.valueNode.form;
                           var data;

                           if (this.minimalGET) {
                               data = {
                                   action: this.get('value'),
                                   type: f.type.value,
                                   id: f.id.value,
                                   vc: f.vc.value,
                                   formname: f.formname.value,
                                   language_code: f.language_code.value,
                                   media: 'screen',
                                   format: f.format.value
                               };
                           }
                           else {
                               data = domform.toObject(f);
                               data['action'] = this.get('value');
                           }

                           iframe(domattr.get(f, 'action'), {
                               data: data
                           });
                           event.stop(evt);
                           return;
                       }

                       return this.inherited(arguments);
                   }
               });
       });
