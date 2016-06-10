/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
 
package avmplus
{
	/**
	 * Makes the hidden, inofficial function describeTypeJSON available outside of the avmplus
	 * package.
	 *
	 * <strong>As Adobe doen't officially support this method and it is only visible to client
	 * code by accident, it should only ever be used with runtime-detection and automatic fallback
	 * on describeType.</strong>
	 *
	 * @see http://www.tillschneidereit.de/2009/11/22/improved-reflection-support-in-flash-player-10-1/
	 */
	public class DescribeTypeJSON
	{
		//----------------------              Public Properties             ----------------------//
		public static var available : Boolean = describeTypeJSON != null;
 
		public static const INSTANCE_FLAGS:uint = INCLUDE_BASES | INCLUDE_INTERFACES
			| INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA
			| INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
		public static const CLASS_FLAGS:uint = INCLUDE_INTERFACES | INCLUDE_VARIABLES
			| INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_TRAITS | HIDE_OBJECT;
 
		public static const INCLUDE_BASES:uint = avmplus.INCLUDE_BASES;
		public static const INCLUDE_INTERFACES:uint = avmplus.INCLUDE_INTERFACES;
		public static const INCLUDE_VARIABLES:uint = avmplus.INCLUDE_VARIABLES;
		public static const INCLUDE_ACCESSORS:uint = avmplus.INCLUDE_ACCESSORS;
		public static const INCLUDE_METHODS:uint = avmplus.INCLUDE_METHODS;
		public static const INCLUDE_METADATA:uint = avmplus.INCLUDE_METADATA;
		public static const INCLUDE_CONSTRUCTOR:uint = avmplus.INCLUDE_CONSTRUCTOR;
		public static const INCLUDE_TRAITS:uint = avmplus.INCLUDE_TRAITS;
		public static const INCLUDE_ITRAITS:uint = avmplus.USE_ITRAITS;
		public static const HIDE_OBJECT:uint = avmplus.HIDE_OBJECT;
 
 
		//----------------------               Public Methods               ----------------------//
		public function DescribeTypeJSON()
		{
		}
		public function describeType(target : Object, flags : uint) : Object
		{
			return describeTypeJSON(target, flags);
		}
 
		public function getInstanceDescription(type : Class) : Object
		{
			return describeTypeJSON(type, INSTANCE_FLAGS);
		}
 
		public function getClassDescription(type : Class) : Object
		{
			return describeTypeJSON(type, CLASS_FLAGS);
		}
	}
}