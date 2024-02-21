component displayname="PeopleBean" accessors="true" extends="base.models.bean" {
	property name="id" type="numeric" default="";
	property name="firstName" type="string" default="";
	property name="lastName" type="string" default="";
	property name="email" type="string" default="";
	property name="passwordHash" type="string" default="";
	property name="salt" type="string" default="";
	property name="isActive" type="boolean" default=1;
	property name="roles" type="array";
	property name="permissions" type="array";
}
