package editor.vo
{
	import editor.EditorGlobal;
	import editor.datatype.data.ComposedData;

	public class Scene extends ValueObjectBase
	{
		public var keyword:String;
		
		public var width:int;
		
		public var height:int;
		
		public var layers:Array;
		
		public var type:String;
		
		public var entities:Array;
		
		public function Scene(properties:Object=null)
		{
			super(properties);
		}
		
		public function get template():SceneTemplate {
			return EditorGlobal.DATA_MEMORY.getSceneTeamplate(type);
		}
		
		public function hasEntity(enti:ComposedData):Boolean {
			return entities.indexOf(enti) >= 0;
		}
	}
}