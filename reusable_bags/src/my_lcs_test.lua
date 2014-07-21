LCS = require('libs.LCS') 
A = LCS.class()

function A:toot()
    print("A: toot!")
end

function A:__add(a,b)
    return "hello"
end

B = A:extends {name = "B"}
function B:init(name) 
    self.name = name 
end 

function B:toot()
    self:super("toot")
    print("B: toot!")
end
function B:__add(a,b)
    print(self:super("__add"))
    return "suck it, love B"
end


a = A()
a:toot()

b = B("bee")
b:toot()

print(a+b)
print(b+a)

a.toot()

print("end tests")