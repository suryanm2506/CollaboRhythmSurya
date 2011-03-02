/**
 * Copyright 2011 John Moore, Scott Gilroy
 *
 * This file is part of CollaboRhythm.
 *
 * CollaboRhythm is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any later
 * version.
 *
 * CollaboRhythm is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with CollaboRhythm.  If not, see
 * <http://www.gnu.org/licenses/>.
 */
package collaboRhythm.shared.apps.equipment.controller
{
//	import collaboRhythm.workstation.apps.equipment.view.EquipmentFullView;

	import collaboRhythm.shared.apps.equipment.view.EquipmentWidgetView;
	import collaboRhythm.shared.controller.apps.AppControllerConstructorParams;
	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import mx.core.UIComponent;

	public class EquipmentAppController extends WorkstationAppControllerBase
	{
		private var _widgetView:EquipmentWidgetView;
//		private var _fullView:EquipmentFullView;
		
		public override function get widgetView():UIComponent
		{
			return _widgetView;
		}
		
		public override function set widgetView(value:UIComponent):void
		{
			_widgetView = value as EquipmentWidgetView;
		}
		
//		public override function get fullView():UIComponent
//		{
//			return _fullView;
//		}
//		
//		public override function set fullView(value:UIComponent):void
//		{
//			_fullView = value as EquipmentFullView;
//		}
		
		public function EquipmentAppController(constructorParams:AppControllerConstructorParams)
		{
			super(constructorParams);
		}
		
		protected override function createWidgetView():UIComponent
		{
			return new EquipmentWidgetView();
		}
		
//		protected override function createFullView():UIComponent
//		{
//			return new EquipmentFullView();
//		}
		
		public override function initialize():void
		{
			super.initialize();
//			if (_sharedUser.equipment == null)
//			{
//				_healthRecordService.loadEquipment(_sharedUser);
//			}
//			(_widgetView as EquipmentWidgetView).model = _sharedUser.equipment;
//			_fullView.model = _sharedUser.equipment;
		}
	}
}