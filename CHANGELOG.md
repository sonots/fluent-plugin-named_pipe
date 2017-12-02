## 0.2.0 (2017/12/02)

Changes:

* Drop Windows Support

Enhancenments:

* Create lib/fluent/plugin/fifo.rb as own fifo library because `ruby-fifo` gem looks like not maintained (thanks to m-mizutani)
  * Use `IO.sysread instead` of `File.read` to avoid read blocking 
  * Add error handling for EOF

## 0.1.2 (2015/08/04)

Fixes:

* ruby-fifo 0.1.0 seems to be broken, let me fix to 0.0.1 for now

## 0.1.1 (2015/08/04)

Changes

* Use new formatter and parser plugin API >= fluentd v0.10.58 (thanks to cosmo0920)

## 0.1.0 (2014/11/22)

First version
