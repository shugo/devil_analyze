require "open-uri"
require "nokogiri"
require "json"

BASE_DIR = "http://members.jcom.home.ne.jp/sss-3/shin1/"

DEVIL_FILES = (
  (1..11).map { |i| "L%02d" % i } +
  (1..14).map { |i| "N%02d" % i } +
  (1..11).map { |i| "C%02d" % i } +
  ["Ex01"]
).map { |i|
  "#{BASE_DIR}/shin1devil_#{i}.html"
}

def parse_number(s)
  s.slice(/\d+/)&.to_i
end

devils = DEVIL_FILES.flat_map { |file|
  side = file.slice(/_([A-Za-z]+)\d+\.html\z/, 1)
  html = open(file, "r:cp932:utf-8") { |f| f.read }
  doc = Nokogiri::HTML.parse(html)
  doc.search("br").each do |br|
    br.replace("\n")
  end
  doc.css("body>a>center>table>tr").map { |rows|
    rows.css("table")
  }.reject(&:empty?).map { |tables|
    rows = tables.map { |table|
      table.css("td").map(&:inner_text)
    }
    {
      "名前" => rows[0][0],
      "LV" => parse_number(rows[0][1]),
      "HP" => parse_number(rows[0][2]),
      "MP" => parse_number(rows[0][3]),
      "CP" => parse_number(rows[0][4]),
      "アイテム" => rows[0][5].sub(/アイテム　/, ""),
      "攻撃" => parse_number(rows[1][0]),
      "命中" => parse_number(rows[1][1]),
      "防御" => parse_number(rows[1][2]),
      "回避" => parse_number(rows[1][3]),
      "魔法威力" => parse_number(rows[1][4]),
      "魔法効果" => parse_number(rows[1][5]),
      "魔法/特技" => rows[1][7].split(/[\s\p{Z}]+/),
      "攻撃回数" => rows[2][0].sub(/攻回　/, ""),
      "力" => parse_number(rows[2][1]),
      "知" => parse_number(rows[2][2]),
      "魔" => parse_number(rows[2][3]),
      "体" => parse_number(rows[2][4]),
      "速" => parse_number(rows[2][5]),
      "運" => parse_number(rows[2][6]),
      "特徴" => rows[2][8],
      "属性" => side, 
    }
  }
}
print JSON.pretty_generate(devils)
