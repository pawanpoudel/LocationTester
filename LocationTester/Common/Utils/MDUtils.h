//Thanks Wil
//http://wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing isEqual:[NSNull null]]) //JS addition for things like coredata
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline BOOL IsNotEmpty(id thing) {
    if (IsEmpty(thing)) {
        return NO;
    }
    
    return YES;
}