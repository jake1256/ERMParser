###################################################################
#
# ERMasterで作成した.ermファイルをパースしてjavaソースを吐き出す
#
###################################################################

# 再帰的にreferenced_columnを探す
def find_ref(ref)
	refId = ref["refId"]
	return ref["wordId"] if refId.to_i == -1
	ref2 = @refList[refId]
	ref = find_ref(ref2)
end


##################################################################
# exec

require 'rexml/document'
require './javaWriter.rb'


###########
# field

# java package name
@packageName = ""

# erm file path
@filePath = ""

# output directory
@outputDir = "output/"

@TAB = "\t"
@DEL = 'del_flg'
@MODI = 'modi_dt'
@REG = 'reg_dt'


doc = REXML::Document.new(open(@filePath))
wordList = Hash.new("none")
tableList = Hash.new('none')
@refList = Hash.new("none")
@pKeyList = Hash.new("none")


# dictionaryのwordタグ一覧を取得

doc.elements.each('diagram/dictionary/word') do |element|
  id = element.elements["id"].text
  physicalName = element.elements["physical_name"].text
  type = element.elements["type"].text
  
  map = {"id" => id , "name" => physicalName , "type" => type }
  
  wordList[id] = map
end

map = {"id" => 10000 , "name" => @DEL  , "type" => "integer" }
wordList[10000] = map

map = {"id" => 10001 , "name" => @MODI , "type" => "datetime" }
wordList[10001] = map

map = {"id" => 10002 , "name" => @REG , "type" => "datetime" }
wordList[10002] = map

# tableデータ


doc.elements.each('diagram/contents/table') do |element|

	tableName = element.elements["physical_name"].text
	
	columnList = []
	element.elements.each('columns/normal_column') do |col|
		id = col.elements["id"].text
		pKey = 0
		wordId = -1
		wordEle = col.elements["word_id"]
		if wordEle != nil then
			wordId = wordEle.text
		end
		
		refId = -1
		refEle = col.elements["referenced_column"]
		if refEle != nil then
			refId = refEle.text
		end
		
		if col.elements["primary_key"].text == "true" then pKey = 1 end
			
		
		column = {"id" => id , "wordId" => wordId , "refId" => refId , "pKey" => pKey}
		
		@refList[id] = column
		columnList.push(column)
	end
	
	column = {"id" => 10000 , "wordId" => 10000 , "refId" => -1 , "pKey" => 0}
	columnList.push(column)
	
	column = {"id" => 10001 , "wordId" => 10001 , "refId" => -1 , "pKey" => 0}
	columnList.push(column)
	
	column = {"id" => 10002 , "wordId" => 10002 , "refId" => -1 , "pKey" => 0}
	columnList.push(column)

	tableList[tableName] = columnList
end


# merge
tableList.keys.each do |key|
	data = tableList[key]
	
	pKey = ''
	data.each do |d|
		wordId = find_ref(d)
		word = wordList[wordId]
		d["word"] = word
		
		val = d["pKey"]
		name = word["name"]
		if val == 1 then
			pKey << name + ' , '
		end
	end
	
	if !pKey.empty? then
		pKey = pKey[0 , pKey.length - 3] # 末尾の , を除去
	end
	@pKeyList[key + '_pKey'] = pKey
end


# output
tableList.keys.each do |key|
	model = File.open(@outputDir + createClass(key) + ".java" , "w")
	sqlFile = File.open(@outputDir + createClass(key) + "Dao.xml" , "w")
	service = File.open(@outputDir + createClass(key) + "Service.java" , "w")
	dao = File.open(@outputDir + createClass(key) + "Dao.java" , "w")
	
	data = tableList[key]
	pKey = @pKeyList[key + '_pKey']
	
	printModel(model , key , data , pKey)
	printSelectSql(sqlFile , key , data , pKey)
	printInsertSql(sqlFile , key , data , pKey)
	printUpdateSql(sqlFile , key , data , pKey)
	printDeleteSql(sqlFile , key , data , pKey)
	printService(service , key , data , pKey)
	printDao(dao , key , data , pKey)
	
	model.close()
	sqlFile.close()
	service.close()
	dao.close()
end




