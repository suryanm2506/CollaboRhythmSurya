package collaboRhythm.plugins.insulinTitrationSupport.view
{
	import collaboRhythm.plugins.insulinTitrationSupport.model.InsulinTitrationDecisionPanelModel;
	import collaboRhythm.plugins.insulinTitrationSupport.view.skins.SolidFillButtonSkin;
	import collaboRhythm.plugins.insulinTitrationSupport.view.skins.TransparentButtonSkin;
	import collaboRhythm.shared.ui.healthCharts.view.SynchronizedHealthCharts;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import flashx.textLayout.conversion.TextConverter;

	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;

	import spark.components.Button;
	import spark.components.CalloutButton;
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.SpinnerList;
	import spark.components.SpinnerListContainer;
	import spark.core.SpriteVisualElement;
	import spark.filters.ColorMatrixFilter;
	import spark.primitives.Rect;
	import spark.skins.mobile.SpinnerListContainerSkin;
	import spark.skins.mobile.SpinnerListSkin;

	public class InsulinTitrationDecisionPanel extends Group
	{
		private static const SUGGESTED_CHANGE_LABEL_COLOR:int = 0x000000;
		private static const OTHER_CHANGE_LABEL_COLOR:int = 0xBFBFBF;
		private static const SUGGESTED_CHANGE_BACKGROUND_COLOR:int = 0xF7941E;
		private static const OTHER_CHANGE_BACKGROUND_COLOR:int = 0xFFFFFF;

		private static const PREREQUISITE_SATISFIED_ARROW_ALPHA:Number = 1;
		private static const PREREQUISITE_NOT_SATISFIED_ARROW_ALPHA:Number = 0.25;
		private static const STEP_ARROW_BUTTON_WIDTH:int = 48;

		private static const STEP1_X:int = 48;
		private static const STEP2_X:int = 208;
		private static const STEP3_X:int = 368;

		private static const STEP_WIDTH:int = 110;
		private static const GOAL_LABEL_VERTICAL_OFFSET:Number = 3;

		public static const INSULIN_DOSE_CHANGE_SPINNER_LIST_MAX:int = 6;

		private var _model:InsulinTitrationDecisionPanelModel;

		private var _dosageChangeSpinnerList:SpinnerList;
		private var _dosageChangeSpinnerListContainer:SpinnerListContainer;
		private var _arrow1CalloutButton:CalloutButton;
		private var _arrow2CalloutButton:CalloutButton;
		private var _arrow3CalloutButton:CalloutButton;
		private var _dosageIncreaseButton:Button;
		private var _dosageNoChangeButton:Button;
		private var _dosageDecreaseButton:Button;

		public var _chartY:Number;
		private var _chartHeight:Number;

		private var _step1Chart:Array;
		private var _step2Chart:Array;

		private var _averagePlotItemRenderer:AverageBloodGlucosePotItemRenderer;
		private var _dosageChangeSpinnerListData:ArrayCollection;

		private var _grayScaleFiler:ColorMatrixFilter = new ColorMatrixFilter([0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);
		private var _step1Badge:Step1Badge;
		private var _step2Badge:Step2Badge;
		private var _step3Badge:Step3Badge;


		public function InsulinTitrationDecisionPanel()
		{
			minHeight = SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT * 2;
			minWidth = STEP3_X + STEP_WIDTH;
		}

		override protected function measure():void
		{
			super.measure();
		}

		override protected function createChildren():void
		{
			super.createChildren();

			_step1Badge = new Step1Badge();
			_step1Badge.bottom = 0;
			_step1Badge.x = STEP1_X;
			updateBadge(_step1Badge, _model.step1State);
			addElement(_step1Badge);

			_step2Badge = new Step2Badge();
			_step2Badge.bottom = 0;
			_step2Badge.x = STEP2_X;
			updateBadge(_step2Badge, _model.step2State);
			addElement(_step2Badge);

			_step3Badge = new Step3Badge();
			_step3Badge.bottom = 0;
			_step3Badge.x = STEP3_X;
			updateBadge(_step3Badge, _model.step3State);
			addElement(_step3Badge);

			_arrow1CalloutButton = createArrowCalloutButton(0, _model.step1State, _model.step1StateDescription);
			_arrow2CalloutButton = createArrowCalloutButton(STEP2_X - STEP_ARROW_BUTTON_WIDTH, _model.step2State,
					_model.step2StateDescription);
			_arrow3CalloutButton = createArrowCalloutButton(STEP3_X - STEP_ARROW_BUTTON_WIDTH, _model.step3State,
					_model.step3StateDescription);

			_chartY = 1;
			determineChartHeight();
			_step1Chart = createChart(STEP1_X, true);
			_step2Chart = createChart(STEP2_X, false);
			_dosageIncreaseButton = createDosageChangeButton(_chartY, 57, _model.dosageIncreaseText + " Units", getDosageChangeLabelColor(_model.algorithmSuggestsIncreaseDose), _model.dosageIncreaseValue);
			_dosageNoChangeButton = createDosageChangeButton(58, 48, "No Change", getDosageChangeLabelColor(_model.algorithmSuggestsNoChangeDose), 0);
			_dosageDecreaseButton = createDosageChangeButton(106, 33, _model.dosageDecreaseText + " Units", getDosageChangeLabelColor(_model.algorithmSuggestsDecreaseDose), _model.dosageDecreaseValue);
			updateDosageChangeButtons();

			_averagePlotItemRenderer = new AverageBloodGlucosePotItemRenderer();
			_averagePlotItemRenderer.x = 102 - _averagePlotItemRenderer.width / 2;
			updateAveragePlotItemRenderer();
			addElement(_averagePlotItemRenderer);

			_dosageChangeSpinnerListContainer = new SpinnerListContainer();
			_dosageChangeSpinnerListContainer.x = STEP3_X;
			_dosageChangeSpinnerListContainer.bottom = SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT;
			_dosageChangeSpinnerListContainer.width = STEP_WIDTH;
			_dosageChangeSpinnerList = new SpinnerList();
			_dosageChangeSpinnerListContainer.addElement(_dosageChangeSpinnerList);
			_dosageChangeSpinnerList.setStyle("skinClass", SpinnerListSkin);
			_dosageChangeSpinnerList.setStyle("textAlign", "right");
			_dosageChangeSpinnerListContainer.setStyle("skinClass", SpinnerListContainerSkin);
			_dosageChangeSpinnerList.percentWidth = 100;
			var spinnerData:ArrayCollection = new ArrayCollection();
			for (var i:Number = INSULIN_DOSE_CHANGE_SPINNER_LIST_MAX; i >= -INSULIN_DOSE_CHANGE_SPINNER_LIST_MAX; i--)
			{
				spinnerData.addItem(i);
			}
			_dosageChangeSpinnerListData = spinnerData;
			_dosageChangeSpinnerList.labelFunction = dosageChangeLabelFunction;
			_dosageChangeSpinnerList.dataProvider = spinnerData;
			setDosageChangeSpinnerListSelectedItem(_model.dosageChangeValue, false);
			_dosageChangeSpinnerList.addEventListener(Event.CHANGE, dosageChangeSpinnerList_changeHandler);
			_dosageChangeSpinnerList.wrapElements = false;

			BindingUtils.bindSetter(model_dosageChangeValue_changeHandler, _model, "dosageChangeValue");

			addElement(_dosageChangeSpinnerListContainer);
		}

		private function updateBadge(badge:SpriteVisualElement, stepState:String):void
		{
			if (stepState != InsulinTitrationDecisionPanelModel.STEP_SATISFIED)
			{
				badge.filters = [_grayScaleFiler];
				badge.alpha = 0.3;
			}
			else
			{
				badge.filters = [];
				badge.alpha = 1;
			}
		}

		protected function dosageChangeLabelFunction(value:Number):String
		{
			if (isNaN(value))
				return "";
			else if (value == 0)
				return "No Change";
			else
				return (value > 0 ? "+" : "") + value.toString() + " Units";
		}

		private function model_dosageChangeValue_changeHandler(value:Number):void
		{
			setDosageChangeSpinnerListSelectedItem(_model.dosageChangeValue);
		}

		protected function setDosageChangeSpinnerListSelectedItem(value:Number, animate:Boolean = true):void
		{
			var selectedItem:Number = isNaN(value) ? 0 : value;
			if (animate)
			{
				var index:int = _dosageChangeSpinnerListData.getItemIndex(selectedItem);
				_dosageChangeSpinnerList.mx_internal::animateToSelectedIndex(index);
			}
			else
			{
				_dosageChangeSpinnerList.selectedItem = selectedItem;
			}
		}

		private function updateAveragePlotItemRenderer():void
		{
			if (_model.isAverageAvailable)
			{
				if (_model.areBloodGlucoseRequirementsMet)
				{
					_averagePlotItemRenderer.alpha = 1;
				}
				else
				{
					_averagePlotItemRenderer.alpha = 0.5
				}

				_averagePlotItemRenderer.y = chartValueToPosition(_model.bloodGlucoseAverage) -
						_averagePlotItemRenderer.height / 2;
				_averagePlotItemRenderer.visible = true;
			}
			else
			{
				_averagePlotItemRenderer.visible = false;
			}
		}

		private function updateDosageChangeButtons():void
		{
			_dosageNoChangeButton.y = chartValueToPosition(_model.goalZoneMaximum) + 1;
			_dosageDecreaseButton.y = chartValueToPosition(_model.goalZoneMinimum) + 1;
			_dosageIncreaseButton.height = _dosageNoChangeButton.y - _dosageIncreaseButton.y - 1;
			_dosageNoChangeButton.height = _dosageDecreaseButton.y - _dosageNoChangeButton.y - 1;
			_dosageDecreaseButton.height = chartValueToPosition(_model.verticalAxisMinimum) - _dosageDecreaseButton.y + 1;

			// TODO: need to invalidateDisplayList when any inputs to algorithm change so that the button label colors will be updated
			setStylesForSuggestedAction(_dosageIncreaseButton, _model.algorithmSuggestsIncreaseDose);
			setStylesForSuggestedAction(_dosageNoChangeButton, _model.algorithmSuggestsNoChangeDose);
			setStylesForSuggestedAction(_dosageDecreaseButton, _model.algorithmSuggestsDecreaseDose);
		}

		private function setStylesForSuggestedAction(button:Button, isSuggested:Boolean):void
		{
			button.setStyle("color", getDosageChangeLabelColor(isSuggested));
			button.setStyle("chromeColor", isSuggested ? SUGGESTED_CHANGE_BACKGROUND_COLOR : OTHER_CHANGE_BACKGROUND_COLOR);
			button.setStyle("skinClass", isSuggested ? SolidFillButtonSkin : TransparentButtonSkin);
		}

		private function determineChartHeight():void
		{
			_chartHeight = Math.max(height, minHeight) - SynchronizedHealthCharts.ADHERENCE_STRIP_CHART_HEIGHT - 1 - 2;
		}

		public function createChart(x:int, showLabels:Boolean):Array
		{
			var chartBorder:Rect = new Rect();
			chartBorder.x = x;
			chartBorder.width = STEP_WIDTH;
			chartBorder.stroke = new SolidColorStroke();
			chartBorder.fill = new SolidColor(0xFFFFFF);

			var goalMaxLine:DottedLine = createGoalLine(x);
			var goalMinLine:DottedLine = createGoalLine(x);
			if (showLabels)
			{
				var goalMaxLabel:Label = createGoalLabel(x, _model.goalZoneMaximum);
				var goalMinLabel:Label = createGoalLabel(x, _model.goalZoneMinimum);
			}
			var chart:Array = [chartBorder, goalMaxLine, goalMinLine, goalMaxLabel, goalMinLabel];
			resizeChart(chart);

			addElement(chartBorder);
			addElement(goalMaxLine);
			addElement(goalMinLine);
			if (showLabels)
			{
				addElement(goalMaxLabel);
				addElement(goalMinLabel);
			}

			return chart;
		}

		private function createGoalLabel(x:int, value:Number):Label
		{
			var goalLabel:Label = new Label();
			goalLabel.setStyle("fontSize", 21);
			goalLabel.setStyle("color", 0x231F20);
			goalLabel.text = value.toString();
//			goalLabel.x = x + STEP_WIDTH - goalLabel.width;
			goalLabel.right = minWidth - (x + STEP_WIDTH);
			return goalLabel;
		}

		private function createGoalLine(x:int):DottedLine
		{
			var goalLine:DottedLine = new DottedLine();
			goalLine.dotColor = 0x808285;
			goalLine.dotWidth = 12;
			goalLine.spacerWidth = 12;
			goalLine.dotHeight = 1;
			goalLine.spacerHeight = 1;
			goalLine.x = x + 1;
			goalLine.width = STEP_WIDTH - 1;
			goalLine.height = 1;
			return goalLine;
		}

		private function resizeChart(chart:Array):void
		{
			var chartBorder:Rect = chart[0];
			var goalMaxLine:DottedLine = chart[1];
			var goalMinLine:DottedLine = chart[2];
			var goalMaxLabel:Label = chart[3];
			var goalMinLabel:Label = chart[4];

			chartBorder.y = _chartY - 1;
			chartBorder.height = _chartHeight + 2;
			goalMaxLine.y = chartValueToPosition(_model.goalZoneMaximum);
			goalMinLine.y = chartValueToPosition(_model.goalZoneMinimum);
			if (goalMaxLabel)
				goalMaxLabel.y = goalMaxLine.y - goalMaxLabel.height + GOAL_LABEL_VERTICAL_OFFSET;
			if (goalMinLabel)
				goalMinLabel.y = goalMinLine.y - goalMinLabel.height + GOAL_LABEL_VERTICAL_OFFSET;
		}

		private function chartValueToPosition(bloodGlucoseAverage:Number):Number
		{
			return Math.round(map(bloodGlucoseAverage, _model.verticalAxisMinimum, _model.verticalAxisMaximum, _chartY + _chartHeight, _chartY));
		}

		private static function map(x:Number, inMin:Number, inMax:Number, outMin:Number, outMax:Number):Number
		{
			return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
		}

		private function getDosageChangeLabelColor(isSuggested:Boolean):int
		{
			return isSuggested ? SUGGESTED_CHANGE_LABEL_COLOR : OTHER_CHANGE_LABEL_COLOR;
		}

		private function createDosageChangeButton(y:int, height:int, label:String, labelColor:int,
												  dosageChangeValue:Number):Button
		{
			var button:Button = new Button();
			button.setStyle("skinClass", TransparentButtonSkin);
			button.x = STEP2_X + 1;
			button.y = y;
			button.width = STEP_WIDTH - 1;
			button.height = height;
			button.label = label;
			button.setStyle("color", labelColor);
			button.addEventListener(MouseEvent.CLICK,
			            function(event:MouseEvent):void {
							setDosageChangeSpinnerListSelectedItem(dosageChangeValue);
							_model.dosageChangeValue = dosageChangeValue;
			            });
			addElement(button);
			return button;
		}

		private function createArrowCalloutButton(x:int, stepState:String, stepStateDescription:String):CalloutButton
		{
			var calloutButton:CalloutButton = new CalloutButton();
			calloutButton.setStyle("skinClass", TransparentButtonSkin);
			calloutButton.setStyle("paddingLeft", 8);
			calloutButton.setStyle("paddingRight", 8);
			calloutButton.setStyle("paddingTop", 8);
			calloutButton.setStyle("paddingBottom", 8);
			updateArrow(calloutButton, stepState, stepStateDescription);
			calloutButton.x = x;
			updateArrowButtonY(calloutButton);
			addElement(calloutButton);
			return calloutButton;
		}

		private function updateArrowButtonY(calloutButton:CalloutButton):void
		{
			calloutButton.y = _chartHeight / 2 - calloutButton.height / 2;
		}

		private function updateArrow(calloutButton:CalloutButton, stepState:String,
									 stepStateDescription:String):void
		{
			var arrow:IVisualElement;
			var contentArray:Array = new Array();
			var richText:RichText = new RichText();
			richText.setStyle("paddingTop", 5);
			richText.setStyle("paddingBottom", 5);
			richText.setStyle("paddingLeft", 5);
			richText.setStyle("paddingRight", 5);
			richText.setStyle("fontSize", 24);
			richText.percentWidth = 100;
			richText.percentHeight = 100;
			// This is a workaround for an what seems to be a bug in the CalloutButton. Without setting the width the
			// Callout will be positioned incorrectly, perhaps because of the way that the flow layout of the RichText
			// elements work.
			richText.addEventListener(Event.ADDED_TO_STAGE, function (event:Event):void
				{
					richText.width = stage.width * 0.5;
					stage.addEventListener(Event.RESIZE, function (event:Event):void
						{
							richText.width = stage.width * 0.5;
						});
				});
			switch (stepState)
			{
				case InsulinTitrationDecisionPanelModel.STEP_SATISFIED:
					arrow = new DecisionSupportArrow();
					richText.textFlow = TextConverter.importToFlow("The requirements for this step of the algorithm have been satisfied. " + stepStateDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
				case InsulinTitrationDecisionPanelModel.STEP_STOP:
					arrow = new DecisionSupportArrowStop();
					richText.textFlow = TextConverter.importToFlow("The requirements for this step of the algorithm have <b>not</b> been satisfied. " + stepStateDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
				default:
					arrow = new DecisionSupportArrowDisabled();
					richText.textFlow = TextConverter.importToFlow("The requirements for a <b>previous</b> step of the algorithm have <b>not</b> been satisfied. " + stepStateDescription, TextConverter.TEXT_FIELD_HTML_FORMAT);
					break;
			}
			calloutButton.setStyle("icon", arrow);
			contentArray.push(richText);
			calloutButton.calloutContent = contentArray;
		}

		private function dosageChangeSpinnerList_changeHandler(event:Event):void
		{
			_model.dosageChangeValue = _dosageChangeSpinnerList.selectedItem;
		}

		public function get model():InsulinTitrationDecisionPanelModel
		{
			return _model;
		}

		public function set model(value:InsulinTitrationDecisionPanelModel):void
		{
			if (_model)
				_model.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler);

			_model = value;

			_model.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, model_propertyChangeHandler, false, 0, true);
		}

		private function model_propertyChangeHandler(event:PropertyChangeEvent):void
		{
			if (event.property == "step1State" || event.property == "step1StateDescription")
			{
				updateArrow(_arrow1CalloutButton, _model.step1State, _model.step1StateDescription);
				updateBadge(_step1Badge, model.step1State);
			}
			if (event.property == "step2State" || event.property == "step2StateDescription")
			{
				updateArrow(_arrow2CalloutButton, _model.step2State, _model.step2StateDescription);
				updateBadge(_step2Badge, model.step2State);
			}
			if (event.property == "step3State" || event.property == "step3StateDescription")
			{
				updateArrow(_arrow3CalloutButton, _model.step3State, _model.step3StateDescription);
				updateBadge(_step3Badge, model.step3State);
			}
			if (event.property == "bloodGlucoseAverage")
			{
				invalidateDisplayList();
			}
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);

			determineChartHeight();
			resizeChart(_step1Chart);
			resizeChart(_step2Chart);
			updateDosageChangeButtons();
			updateAveragePlotItemRenderer();
			updateArrowButtonY(_arrow1CalloutButton);
			updateArrowButtonY(_arrow2CalloutButton);
			updateArrowButtonY(_arrow3CalloutButton);
			_dosageChangeSpinnerListContainer.height = _chartHeight;
		}
	}
}
