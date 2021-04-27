# KTPropertyCheck
check mis-typing attrbute perpoerty('object type' with 'assign' mem attribute ) in image(executable, dynamic library, etc)

# Usaged

Putting class (any of classes contained in target image) to `KTPropertyCheck` as below:

```objc
[KTPropertyCheck checkImagesThatContainClasses:@[Foo.class]];
```

It would show you the obejct type porperty with assign attribute:
```
KTPropertyCheck: bar in class: Foo
```

# Usaged
Maybe MIT. But I'm too lazy to care about it. 🚑
