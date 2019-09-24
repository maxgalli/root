import libcppyy

def getAllClasses():
    TClassTable = libcppyy.CreateScopeProxy('TClassTable')
    TClassTable.Init()
    classes = []
    while True :
        c = TClassTable.Next()
        if c : classes.append(c)
        else : break
    return classes

