## 地图配置数据
## 每张地图包含: 名称、大小、NPC列表(名称+位置)、传送区域、连接地图

class_name MapsDB

## 地图枚举
enum MapID {
	LANHE_VILLAGE,       # 1 蓝河村
	VILLAGE_PLAIN,       # 2 村外平原
	WINDROCK_STREET,     # 3 风岩城·街道
	WINDROCK_MARKET,     # 4 风岩城·市场
	STORM_TAVERN,        # 5 暴风酒馆
	STORM_CHURCH,        # 6 风暴教堂
	ICE_PATH,            # 7 北方冰原小径
	ETERNAL_KINGDOM,     # 8 永恒王国·城镇
	DARK_FOREST_EDGE,    # 9 永夜森林边缘
	DARK_FOREST_DEEP,    # 10 永夜森林深处
	GOLDTRADE_CITY,      # 11 金贸王国·商业区
	ENDLESS_SEA_ISLAND,  # 12 无尽海·神秘岛屿
}

## 地图信息: {id, name, desc, size_x, size_y, tileset, bgm}
## NPC: {name, x, y, is_core}
## 传送区: {x, y, w, h, target_map, target_x, target_y, label}
## 地图连接: {target_map, label, direction}

const MAPS: Dictionary = {
	MapID.LANHE_VILLAGE: {
		"id": 1,
		"name_cn": "蓝河村",
		"name_jp": "藍河村",
		"desc_cn": "起始村庄，河流穿村，木屋农田水车",
		"size_x": 40,
		"size_y": 30,
		"tileset": "village",
		"bgm": "bgm_village",
		"npcs": [
			{"name": "艾琳", "x": 8, "y": 12, "is_core": true},
			{"name": "薇拉", "x": 22, "y": 8, "is_core": true},
			{"name": "海伦娜", "x": 36, "y": 18, "is_core": true},
			{"name": "村长托马", "x": 15, "y": 6, "is_core": false},
			{"name": "铁匠格罗", "x": 28, "y": 10, "is_core": false},
			{"name": "渔夫老赵", "x": 34, "y": 20, "is_core": false},
		],
		"transfers": [
			{"x": 20, "y": 0, "w": 4, "h": 1, "target_map": MapID.VILLAGE_PLAIN, "target_x": 20, "target_y": 28, "label": "北出口→村外平原"},
			{"x": 36, "y": 18, "w": 3, "h": 2, "target_map": -1, "label": "码头(海伦娜)"},
		],
		"connections": [
			{"target": MapID.VILLAGE_PLAIN, "label": "北→村外平原"},
		],
	},
	MapID.VILLAGE_PLAIN: {
		"id": 2,
		"name_cn": "村外平原",
		"name_jp": "村外平原",
		"desc_cn": "开阔草地、稀疏树林、商道",
		"size_x": 50,
		"size_y": 40,
		"tileset": "plain",
		"bgm": "bgm_plain",
		"npcs": [
			{"name": "克莱尔", "x": 25, "y": 20, "is_core": true},
			{"name": "农夫老陈", "x": 12, "y": 25, "is_core": false},
			{"name": "商队护卫队长阿德尔", "x": 30, "y": 15, "is_core": false},
			{"name": "流浪商人老何", "x": 18, "y": 30, "is_core": false},
		],
		"transfers": [
			{"x": 20, "y": 39, "w": 4, "h": 1, "target_map": MapID.LANHE_VILLAGE, "target_x": 20, "target_y": 2, "label": "南→蓝河村"},
			{"x": 49, "y": 15, "w": 1, "h": 4, "target_map": MapID.WINDROCK_STREET, "target_x": 2, "target_y": 15, "label": "东→风岩城"},
			{"x": 30, "y": 39, "w": 4, "h": 1, "target_map": MapID.DARK_FOREST_EDGE, "target_x": 20, "target_y": 2, "label": "南偏东→永夜森林边缘"},
		],
		"connections": [
			{"target": MapID.LANHE_VILLAGE, "label": "南→蓝河村"},
			{"target": MapID.WINDROCK_STREET, "label": "东→风岩城"},
			{"target": MapID.DARK_FOREST_EDGE, "label": "南偏东→永夜森林边缘"},
		],
	},
	MapID.WINDROCK_STREET: {
		"id": 3,
		"name_cn": "风岩城·街道",
		"name_jp": "風岩城・街道",
		"desc_cn": "石板路城镇，两侧建筑，城墙城门",
		"size_x": 40,
		"size_y": 30,
		"tileset": "city_street",
		"bgm": "bgm_city",
		"npcs": [
			{"name": "格蕾丝", "x": 20, "y": 10, "is_core": true},
			{"name": "露娜", "x": 30, "y": 8, "is_core": true},
			{"name": "奥莉维亚", "x": 15, "y": 15, "is_core": true},
			{"name": "莉娜", "x": 8, "y": 22, "is_core": true},
			{"name": "梅林达", "x": 35, "y": 5, "is_core": true},
			{"name": "艾米", "x": 32, "y": 18, "is_core": true},
			{"name": "城门卫兵杰克", "x": 2, "y": 15, "is_core": false},
		],
		"transfers": [
			{"x": 0, "y": 13, "w": 1, "h": 4, "target_map": MapID.VILLAGE_PLAIN, "target_x": 47, "target_y": 17, "label": "西门→村外平原"},
			{"x": 12, "y": 0, "w": 3, "h": 1, "target_map": MapID.STORM_TAVERN, "target_x": 15, "target_y": 27, "label": "北巷→暴风酒馆"},
			{"x": 25, "y": 0, "w": 3, "h": 1, "target_map": MapID.WINDROCK_MARKET, "target_x": 20, "target_y": 27, "label": "南巷→市场"},
			{"x": 38, "y": 0, "w": 2, "h": 1, "target_map": -1, "label": "东巷→法师塔(梅林达)"},
			{"x": 38, "y": 29, "w": 2, "h": 1, "target_map": -1, "label": "东巷→宅邸(艾米)"},
		],
		"connections": [
			{"target": MapID.VILLAGE_PLAIN, "label": "西门→村外平原"},
			{"target": MapID.STORM_TAVERN, "label": "北巷→暴风酒馆"},
			{"target": MapID.WINDROCK_MARKET, "label": "南巷→市场"},
			{"target": MapID.ICE_PATH, "label": "北→北方冰原小径"},
		],
	},
	MapID.WINDROCK_MARKET: {
		"id": 4,
		"name_cn": "风岩城·市场",
		"name_jp": "風岩城・市場",
		"desc_cn": "露天摊位、商队马车、喧嚣人群",
		"size_x": 35,
		"size_y": 25,
		"tileset": "market",
		"bgm": "bgm_market",
		"npcs": [
			{"name": "维多利亚", "x": 10, "y": 8, "is_core": true},
			{"name": "蕾娅", "x": 25, "y": 12, "is_core": true},
			{"name": "芙蕾雅", "x": 5, "y": 18, "is_core": true},
			{"name": "商人哈桑", "x": 18, "y": 5, "is_core": false},
			{"name": "矮人铜锤", "x": 28, "y": 8, "is_core": false},
			{"name": "矮人长老铁须", "x": 30, "y": 18, "is_core": false},
		],
		"transfers": [
			{"x": 18, "y": 0, "w": 4, "h": 1, "target_map": MapID.WINDROCK_STREET, "target_x": 26, "target_y": 2, "label": "北→街道"},
		],
		"connections": [
			{"target": MapID.WINDROCK_STREET, "label": "北→街道"},
		],
	},
	MapID.STORM_TAVERN: {
		"id": 5,
		"name_cn": "暴风酒馆",
		"name_jp": "暴風酒場",
		"desc_cn": "室内木质吧台、壁炉、昏暗灯光、小舞台",
		"size_x": 25,
		"size_y": 20,
		"tileset": "tavern",
		"bgm": "bgm_tavern",
		"npcs": [
			{"name": "罗莎", "x": 12, "y": 8, "is_core": true},
			{"name": "米拉", "x": 8, "y": 14, "is_core": true},
			{"name": "妮可", "x": 18, "y": 12, "is_core": true},
			{"name": "佣兵雷恩", "x": 20, "y": 5, "is_core": false},
		],
		"transfers": [
			{"x": 12, "y": 19, "w": 3, "h": 1, "target_map": MapID.WINDROCK_STREET, "target_x": 13, "target_y": 2, "label": "出门→街道"},
		],
		"connections": [
			{"target": MapID.WINDROCK_STREET, "label": "出门→街道"},
		],
	},
	MapID.STORM_CHURCH: {
		"id": 6,
		"name_cn": "风暴教堂",
		"name_jp": "嵐の教会",
		"desc_cn": "高大石柱、彩窗、风暴神像、祈祷室",
		"size_x": 20,
		"size_y": 25,
		"tileset": "church",
		"bgm": "bgm_church",
		"npcs": [
			{"name": "艾琳娜", "x": 10, "y": 8, "is_core": true},
			{"name": "安娜", "x": 5, "y": 15, "is_core": true},
			{"name": "守卫骑士冯", "x": 2, "y": 5, "is_core": false},
			{"name": "教会学徒托马斯", "x": 15, "y": 12, "is_core": false},
		],
		"transfers": [
			{"x": 9, "y": 0, "w": 3, "h": 1, "target_map": MapID.WINDROCK_STREET, "target_x": 20, "target_y": 2, "label": "出门→街道"},
		],
		"connections": [
			{"target": MapID.WINDROCK_STREET, "label": "出门→街道"},
		],
	},
	MapID.ICE_PATH: {
		"id": 7,
		"name_cn": "北方冰原小径",
		"name_jp": "北の氷原小径",
		"desc_cn": "积雪山路、冰晶、上古遗迹石柱、失落的传送阵",
		"size_x": 45,
		"size_y": 50,
		"tileset": "ice",
		"bgm": "bgm_ice",
		"npcs": [
			{"name": "赛琳", "x": 22, "y": 25, "is_core": true},
			{"name": "猎人老冰", "x": 15, "y": 18, "is_core": false},
			{"name": "兽人斥候小灰", "x": 30, "y": 12, "is_core": false},
		],
		"transfers": [
			{"x": 20, "y": 49, "w": 4, "h": 1, "target_map": MapID.WINDROCK_STREET, "target_x": 20, "target_y": 28, "label": "南→风岩城"},
			{"x": 20, "y": 0, "w": 4, "h": 1, "target_map": MapID.ETERNAL_KINGDOM, "target_x": 20, "target_y": 27, "label": "北→永恒王国"},
			{"x": 38, "y": 10, "w": 3, "h": 2, "target_map": MapID.GOLDTRADE_CITY, "target_x": 20, "target_y": 27, "label": "遗迹传送阵→金贸王国"},
		],
		"connections": [
			{"target": MapID.WINDROCK_STREET, "label": "南→风岩城"},
			{"target": MapID.ETERNAL_KINGDOM, "label": "北→永恒王国"},
			{"target": MapID.GOLDTRADE_CITY, "label": "遗迹传送阵→金贸王国"},
		],
	},
	MapID.ETERNAL_KINGDOM: {
		"id": 8,
		"name_cn": "永恒王国·城镇",
		"name_jp": "永遠王国・街",
		"desc_cn": "冰雪覆盖寂静城镇，居民如木偶，灰蓝色调",
		"size_x": 35,
		"size_y": 30,
		"tileset": "eternal",
		"bgm": "bgm_eternal",
		"npcs": [
			{"name": "塞西莉亚", "x": 17, "y": 8, "is_core": true},
			{"name": "罗兰", "x": 20, "y": 10, "is_core": true},
			{"name": "无名铁匠", "x": 8, "y": 20, "is_core": false},
			{"name": "无名面包师", "x": 25, "y": 22, "is_core": false},
			{"name": "无名孩童", "x": 14, "y": 18, "is_core": false},
		],
		"transfers": [
			{"x": 20, "y": 0, "w": 4, "h": 1, "target_map": MapID.ICE_PATH, "target_x": 20, "target_y": 48, "label": "南→冰原小径"},
		],
		"connections": [
			{"target": MapID.ICE_PATH, "label": "南→冰原小径"},
		],
	},
	MapID.DARK_FOREST_EDGE: {
		"id": 9,
		"name_cn": "永夜森林边缘",
		"name_jp": "永夜の森・縁",
		"desc_cn": "巨木参天、藤蔓密布、光线昏暗、兽人部落",
		"size_x": 40,
		"size_y": 35,
		"tileset": "forest_edge",
		"bgm": "bgm_forest",
		"npcs": [
			{"name": "阿尔忒弥斯", "x": 30, "y": 10, "is_core": true},
			{"name": "希尔薇", "x": 12, "y": 20, "is_core": true},
			{"name": "塔玛拉", "x": 35, "y": 25, "is_core": true},
			{"name": "琳达", "x": 8, "y": 28, "is_core": true},
			{"name": "兽人老猎人铁爪", "x": 28, "y": 18, "is_core": false},
		],
		"transfers": [
			{"x": 18, "y": 0, "w": 4, "h": 1, "target_map": MapID.VILLAGE_PLAIN, "target_x": 30, "target_y": 38, "label": "北→村外平原"},
			{"x": 20, "y": 34, "w": 4, "h": 1, "target_map": MapID.DARK_FOREST_DEEP, "target_x": 20, "target_y": 2, "label": "南→永夜森林深处(需解锁)"},
		],
		"connections": [
			{"target": MapID.VILLAGE_PLAIN, "label": "北→村外平原"},
			{"target": MapID.DARK_FOREST_DEEP, "label": "南→永夜森林深处(需解锁)"},
		],
	},
	MapID.DARK_FOREST_DEEP: {
		"id": 10,
		"name_cn": "永夜森林深处",
		"name_jp": "永夜の森・奥",
		"desc_cn": "密林、发光蘑菇、精灵聚落、魔兽出没",
		"size_x": 35,
		"size_y": 35,
		"tileset": "forest_deep",
		"bgm": "bgm_forest_deep",
		"npcs": [
			{"name": "艾露恩", "x": 17, "y": 15, "is_core": true},
		],
		"transfers": [
			{"x": 15, "y": 0, "w": 4, "h": 1, "target_map": MapID.DARK_FOREST_EDGE, "target_x": 20, "target_y": 32, "label": "北→森林边缘"},
		],
		"connections": [
			{"target": MapID.DARK_FOREST_EDGE, "label": "北→森林边缘"},
		],
	},
	MapID.GOLDTRADE_CITY: {
		"id": 11,
		"name_cn": "金贸王国·商业区",
		"name_jp": "金貿王国・商業区",
		"desc_cn": "繁华都市、各国商队、中立地带、大型建筑",
		"size_x": 45,
		"size_y": 35,
		"tileset": "goldtrade",
		"bgm": "bgm_goldtrade",
		"npcs": [
			{"name": "伊莎贝拉", "x": 22, "y": 8, "is_core": true},
			{"name": "索菲亚", "x": 35, "y": 15, "is_core": true},
			{"name": "凯瑟琳", "x": 10, "y": 20, "is_core": true},
			{"name": "冒险者公会接待员贝蒂", "x": 8, "y": 10, "is_core": false},
		],
		"transfers": [
			{"x": 20, "y": 17, "w": 3, "h": 2, "target_map": MapID.ICE_PATH, "target_x": 38, "target_y": 12, "label": "传送阵→北方冰原"},
			{"x": 38, "y": 17, "w": 3, "h": 2, "target_map": MapID.WINDROCK_STREET, "target_x": 38, "target_y": 15, "label": "传送阵→风岩城"},
		],
		"connections": [
			{"target": MapID.ICE_PATH, "label": "传送阵→北方冰原"},
			{"target": MapID.WINDROCK_STREET, "label": "传送阵→风岩城"},
		],
	},
	MapID.ENDLESS_SEA_ISLAND: {
		"id": 12,
		"name_cn": "无尽海·神秘岛屿",
		"name_jp": "果てなき海・神秘の島",
		"desc_cn": "火山岛、龙族遗迹、龙巢、宝藏",
		"size_x": 30,
		"size_y": 30,
		"tileset": "island",
		"bgm": "bgm_island",
		"npcs": [
			{"name": "妮丝塔", "x": 15, "y": 10, "is_core": true},
		],
		"transfers": [
			{"x": 14, "y": 29, "w": 3, "h": 1, "target_map": MapID.LANHE_VILLAGE, "target_x": 36, "target_y": 19, "label": "船→蓝河村码头"},
		],
		"connections": [
			{"target": MapID.LANHE_VILLAGE, "label": "船→蓝河村码头"},
		],
	},
}

## 获取地图数据
static func get_map(map_id: int) -> Dictionary:
	return MAPS.get(map_id, {})

## 获取地图名称
static func get_map_name(map_id: int) -> String:
	var m: Dictionary = MAPS.get(map_id, {})
	return m.get("name_cn", "未知地图")

## 获取地图NPC列表
static func get_map_npcs(map_id: int) -> Array:
	var m: Dictionary = MAPS.get(map_id, {})
	return m.get("npcs", [])

## 获取地图传送区域
static func get_map_transfers(map_id: int) -> Array:
	var m: Dictionary = MAPS.get(map_id, {})
	return m.get("transfers", [])

## 获取地图连接
static func get_map_connections(map_id: int) -> Array:
	var m: Dictionary = MAPS.get(map_id, {})
	return m.get("connections", [])

## 获取所有地图ID列表
static func get_all_map_ids() -> Array:
	return MAPS.keys()

## 获取地图数量
static func get_map_count() -> int:
	return MAPS.size()
