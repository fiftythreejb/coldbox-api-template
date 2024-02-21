/**
 * I model a modTemplate bean
 */
component accessors="true" extends="base.models.bean" displayname="ModTemplateBean"{

	// Properties
	property name="id" type="numeric" default="0" primary=true;
	property name="title" type="string" default="";
	property name="createdOn" type="date" default="#now()#";
	property name="updatedOn" type="date" default="#now()#";
	property name="isActive" type="boolean" default="true"; 
}