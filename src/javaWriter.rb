####################################################################
# util 周り

# column名からField名に変換(test_master -> testMaster)
def createField(str)
	split = str.split("_");
	result = ''
	i = 0
	split.each do |s|
		if s == "lshooting" then
			next
		end
		
		if i == 0 then
			result += s
		else
			one = s[0]
			two = s[1 , s.size]
			result += one.upcase
			result += two.downcase
		end
		
		i += 1
	end
	return result
end

# column名からClass名に変換(test_master -> TestMaster)
def createClass(str)
	split = str.split("_");
	result = ''

	split.each do |s|
		if s == "lshooting" || s == "master" then
			next
		end
		
		one = s[0]
		two = s[1 , s.size]
		result += one.upcase
		result += two.downcase

	end
	return result
end

# 型名を変換する
def createTypeName(str)
	result = 
		case str
			when 'integer' then "int"
			when 'varchar(n)' then "String"
			when 'datetime' then "Date"
			else ""
		end
	return result
end

# 主キーを変換
def printPkey(pKey)
	split = pKey.split(" , ");
	result = ''
	split.each_with_index do |s , index|
		result += @TAB + @TAB + s + ' = #' + createField(s) + '#' + "\n"
		if index != split.length - 1 then
			result += @TAB + 'and' + "\n"
		end
	end
	
	return result
end

####################################################################
# java class 周り

# modelを出力
def printModel(file , key , data , pKey)
	file.puts 'public class ' + createClass(key) + ' {'
	data.each do |d|
		word = d["word"]
		file.puts @TAB + 'private ' + createTypeName(word["type"]) + ' ' + createField(word["name"]) + ';'
	end
	
	file.puts ''
	data.each do |d|
		word = d["word"]
		type = createTypeName(word["type"])
		nameC = createClass(word["name"])
		nameF = createField(word["name"])
		
		file.puts @TAB + 'public ' + type + ' get' + nameC + '(){'
		file.puts @TAB + @TAB + 'return ' + nameF + ';'
		file.puts @TAB + '}'
		file.puts ''
		
		file.puts @TAB + 'public void set' + nameC + '(' + type + ' ' + nameF + '){'
		file.puts @TAB + @TAB + 'this.' + nameF + ' = ' + nameF + ';'
		file.puts @TAB + '}'
		file.puts ''
	end
	
	file.puts '}'
end

# serviceを出力
def printService(file , key , data , pKey)
	file.puts 'public class ' + createClass(key) + 'Service{'
	
	file.puts @TAB + '/** log */'
	file.puts @TAB + 'private Log log = LogFactory.getLog(' + createClass(key) + 'Service.class);'
	file.puts ''
	
	file.puts @TAB + 'private ' + createClass(key) + 'Dao ' + createField(key) + 'Dao;'
	file.puts ''
	
	file.puts @TAB + 'public List<' + createClass(key) + '> find' + createClass(key) + '(){'
	file.puts @TAB + @TAB + 'return ' + createField(key) + 'Dao.select' + createClass(key) + '();'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public ' + createClass(key) + ' find' + createClass(key) + 'ById(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'return ' + createField(key) + 'Dao.select' + createClass(key) + 'ById(' + createField(key) + ');'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public Object insert' + createClass(key) + '(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'return ' + createField(key) + 'Dao.insert' + createClass(key) + '(' + createField(key) + ');'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public int update' + createClass(key) + '(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'return ' + createField(key) + 'Dao.update' + createClass(key) + '(' + createField(key) + ');'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public int delete' + createClass(key) + '(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'return ' + createField(key) + 'Dao.delete' + createClass(key) + '(' + createField(key) + ');'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts '}'
end

# daoを出力
def printDao(file , key , data , pKey)
	file.puts 'public class ' + createClass(key) + 'Dao extends CommonDao{'
	
	file.puts @TAB + 'public List<' + createClass(key) + '> select' + createClass(key) + '(){'
	file.puts @TAB + @TAB + 'return (List<' + createClass(key) + '>)queryForList(STATEMENT_MASTER_PREFIX + "select' + createClass(key) + '");'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public ' + createClass(key) + ' select' + createClass(key) + 'ById(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'return (' + createClass(key) + ')queryForObject(STATEMENT_MASTER_PREFIX + "select' + createClass(key) + 'ById" , id);'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public Object insert' + createClass(key) + '(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'Object o = insert(STATEMENT_MASTER_PREFIX + "insert' + createClass(key) + '" , ' + createField(key) + ');'
	file.puts @TAB + @TAB + 'return o;'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public int update' + createClass(key) + '(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'int result = update(STATEMENT_MASTER_PREFIX + "update' + createClass(key) + '" , ' + createField(key) + ');'
	file.puts @TAB + @TAB + 'return result;'
	file.puts @TAB + '}'
	file.puts ''
	
	file.puts @TAB + 'public int delete' + createClass(key) + '(' + createClass(key) + ' ' + createField(key) + '){'
	file.puts @TAB + @TAB + 'int result = delete(STATEMENT_MASTER_PREFIX + "delete' + createClass(key) + '" , ' + createField(key) + ');'
	file.puts @TAB + @TAB + 'return result;'
	file.puts @TAB + '}'
	
	file.puts '}'
end

####################################################################
# ibatis SQL 周り

# ibatis select sqlを出力
def printSelectSql(file , key , data , pKey)
	file.puts '<select id="select' + createClass(key) +  '" resultClass="' + @packageName + createClass(key) + '">'
	file.puts '<![CDATA['
	file.puts @TAB + 'select '
	data.each do |d|
		word = d["word"]
		name = word["name"]
		if d != data.last then
			file.puts @TAB + @TAB + name + ' as ' + createField(name) + ' ,'
		else
			file.puts @TAB + @TAB + name + ' as ' + createField(name)
		end
	end
	file.puts @TAB + 'from '
	file.puts @TAB + @TAB + key
	file.puts ']]>'
	file.puts '</select>'
	file.puts ''
	file.puts '<select id="select' + createClass(key) +  'ById" resultClass="' + @packageName + createClass(key) + '">'
	file.puts '<![CDATA['
	file.puts @TAB + 'select '
	data.each do |d|
		word = d["word"]
		name = word["name"]
		if d != data.last then
			file.puts @TAB + @TAB + name + ' as ' + createField(name) + ' ,'
		else
			file.puts @TAB + @TAB + name + ' as ' + createField(name)
		end
	end
	file.puts @TAB + 'from '
	file.puts @TAB + @TAB + key
	file.puts @TAB + 'where '
	file.puts printPkey(pKey)
	file.puts ']]>'
	file.puts '</select>'
	file.puts ''
	
end

# ibatis inser Sqlを生成
def printInsertSql(file , key , data , pKey)
	file.puts '<insert id="insert' + createClass(key) +  '" parameterClass="' + @packageName + createClass(key) + '">'
	file.puts '<![CDATA['
	file.puts @TAB + 'insert into ' + key + ' '
	file.print @TAB + @TAB + '('
	data.each do |d|
		word = d["word"]
		name = word["name"]
		if d != data.last then
			file.print name + ' , '
		else
			file.print name
		end
	end
	file.puts ')'
	file.puts @TAB + 'values '
	file.print @TAB + @TAB + '('
	data.each do |d|
		word = d["word"]
		name = word["name"]
		if d != data.last then
			file.print '#' + createField(name) + '# , '
		else
			file.print '#' + createField(name) + '#'
		end
	end
	file.puts ')'
	file.puts ']]>'
	file.puts '</insert>'
	file.puts ''
end

# ibatis update Sqlを生成
def printUpdateSql(file , key , data , pKey)
	file.puts '<update id="update' + createClass(key) +  '" parameterClass="' + @packageName + createClass(key) + '">'
	file.puts '<![CDATA['
	file.puts @TAB + 'update ' + key
	file.puts @TAB + 'set '
	data.each do |d|
		word = d["word"]
		name = word["name"]
		if d != data.last then
			file.puts @TAB + @TAB + name + ' = #' + createField(name) + '# ,'
		else
			file.puts @TAB + @TAB + name + ' = #' + createField(name) + '#'
		end
	end
	file.puts @TAB + 'where '
	file.puts printPkey(pKey)
	file.puts ']]>'
	file.puts '</update>'
	file.puts ''
end

# ibatis delete Sqlを生成
def printDeleteSql(file , key , data , pKey)
	file.puts '<delete id="delete' + createClass(key) +  '" parameterClass="' + @packageName + createClass(key) + '">'
	file.puts '<![CDATA['
	file.puts @TAB + 'delete from ' + key
	file.puts @TAB + 'where '
	file.puts printPkey(pKey)
	file.puts ']]>'
	file.puts '</delete>'
	file.puts ''
end