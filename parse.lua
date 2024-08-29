---@class query_parser
local M = {}
--[[
a query consists of a collections being passed through a series of filters and maps
a filter is defined as : for a default failing filter or ; for a default succeeding filter
a filters default applies when an error occurs
filters are of type filter :: collection<T> -> (T -> bool) -> collection<T>
a map uses | always, and erroring elements are dropped
maps are of type map :: collection<T> -> (T -> U) -> collection<U>
operations inside can generate a collection, which can then by operated on
as a|b|c|d is ((a|b)|c)|d a|(b|c)|d must be used to handle generated collections
functions are called without brackets and consume all arguments
the base collections are S(pells) F(iles) M(aterials), and the result of the nth query is TODO:
. is index
>, <, >=, <=, = are comparisons
c gets content of path
x gets xml of path
ex gets entity xml of path
num converts input to num

]]
return M
