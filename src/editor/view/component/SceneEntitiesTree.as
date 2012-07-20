package editor.view.component
{
	import editor.EditorGlobal;
	import editor.datatype.ReservedName;
	import editor.datatype.data.ComposedData;
	import editor.datatype.impl.parser.xml.XMLDataParser;
	import editor.datatype.type.IDataType;
	import editor.mgr.EntityFactory;
	import editor.mgr.PopupMgr;
	import editor.view.scene.EntityBaseView;
	import editor.vo.Scene;
	
	import mx.collections.ArrayCollection;
	import mx.events.ListEvent;

	public class SceneEntitiesTree extends TreeBase
	{
		public var scene:Scene;
		
		public function SceneEntitiesTree()
		{
			super();
			this.contextMenuEnabled = true;
		}
		
		override public function refreshView(data:Object=null):void {
			var scrollPosition:Number;
			var openedItems:Object;
			scene = data as Scene;
			var entityClassArr:Array = scene.template.entities;
			var dataProvider:ArrayCollection = new ArrayCollection(); // = <node/>;
			for each(var entityClassName:String in entityClassArr) {
				dataProvider.addItem(populateCategory(entityClassName, data as Scene));
//				dataProvider.appendChild(populateCategory(entityClassName, data as Scene));
			}
			this.showRoot = true;
			this.dataProvider = dataProvider;
		}
		
		private function populateCategory(cate_name:String, scene:Scene):XML {
			var categoryTree:XML = <node />;
			var child:XML;
			categoryTree.@label = cate_name;
			categoryTree.@leaf = false;
			
			for each(var entity:ComposedData in scene.entities) {
				if(entity.$type.name != cate_name) continue;
				child = <node />;
				child.@label = entity['keyword'];
				child.@leaf = true;
				child.@template = cate_name;
				categoryTree.appendChild(child);
			}
			
			return categoryTree;
		}
		
		private function getEntiDataByXML(item:XML):ComposedData {
			var enti:ComposedData;
			if(item.@leaf != true) {
				var type:IDataType = EditorGlobal.DATA_MANAGER.getType(item.@label);
				enti = type.construct();
				return enti;
			} else {
				for each(enti in scene.entities) {
					if(enti['keyword'] == item.@label) {
						return enti;
					}
				}
				return null;
			}
		}
		
		override protected function itemClickHandler(evt:ListEvent):void {
			super.itemClickHandler(evt);
			if((this.selectedItem as XML).@leaf == true) {
				var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML);
				if(enti && enti.view) {
					enti.view.selected = true;
				}
			}
		}
		
		override protected function itemDoubleClickHandler(evt:ListEvent):void {
			var something:XML = XMLDataParser.toXML(scene, EditorGlobal.DATA_MANAGER.types);
			var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML);
			editEntity(enti);
		}
		
		override public function get contextMenuItems():Array {
			var ret:Array = [];
			var selectItem:XML = this.selectedItem as XML;
			if(selectItem) {
				var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML); 
				var isEntiLock:Boolean = enti && enti.view && enti.view.lock;
				if(selectItem.@leaf == true) {
					ret = ret.concat([{"label":"编辑", "enabled":true, "handler":ctmEditInstance}
									 ,{"label":"克隆", "enabled":!isEntiLock, "handler":ctmCloneInstance}
									 ,{"label":"删除", "enabled":!isEntiLock, "handler":ctmDeleteInstance}
					]);
				} else {
					ret = ret.concat([{"label":"新建", "enabled":true, "handler":ctmNewInstance}]);
				}
			}
			return ret;
		}
		
		private function ctmEditInstance():void {
			var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML);
			editEntity(enti);
		}
		
		private function editEntity(enti:ComposedData):void {
			if(enti == null) {
				return;
			}
			var isEntiLock:Boolean = enti.view && enti.view.lock;
			EditorGlobal.PROPERTY_WND.title = "Editing "+enti.$type.name;
			EditorGlobal.PROPERTY_WND.target = enti;
			PopupMgr.getInstance().popupWindow(EditorGlobal.PROPERTY_WND);
		}
		
		private function ctmCloneInstance():void {
			var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML);
			if(enti) {
				enti = EntityFactory.cloneEntity(enti);
				enti[ReservedName.KEYWORD] = EntityFactory.buildKeyword(enti.templateName, scene.getEntityCntByTemplate(enti.templateName));
				EditorGlobal.MAIN_WND.addEntity(enti);
			}
		}
		
		private function ctmDeleteInstance():void {
			var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML);
			if(enti) {
				EditorGlobal.MAIN_WND.deleteEntity(enti);
			}
		}
		
		private function ctmNewInstance():void {
			var enti:ComposedData = getEntiDataByXML(this.selectedItem as XML);
			if(enti) {
				enti[ReservedName.KEYWORD] = EntityFactory.buildKeyword(enti.templateName, scene.getEntityCntByTemplate(enti.templateName));
				EditorGlobal.MAIN_WND.addEntity(enti);
			}
		}
	}
}