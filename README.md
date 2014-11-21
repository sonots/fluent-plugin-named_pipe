# fluent-plugin-named_pipe

[![Build Status](https://secure.travis-ci.org/sonots/fluent-plugin-named_pipe.png?branch=master)](http://travis-ci.org/sonots/fluent-plugin-named_pipe)

Named pipe input/output plugin for Fluentd.

# Input Plugin

## Configuration

```apache
<source>
  type named_pipe
  path /path/to/file
  tag foo.bar
  format ltsv
</match>
```

## Parameters

- path

    The file path of the named pipe

- tag

    The emit tag name

- format

    The input format such as regular expression, `apache2`, `ltsv`, etc. Same with `in_tail` plugin. See http://docs.fluentd.org/articles/in_tail

# Output Plugin

## Configuration

```apache
<match foo.bar.**>
  type named_pipe
  path /path/to/file
</match>
```

The output to the named pipe would be like:

```
foo.bar: {"foo":"bar"}
```

## Parameters

- path

    The file path of the named pipe

- format

    The output format such as `out_file`, `json`, `ltsv`, `single_value`. Default is `out_file`. 

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2014 Naotoshi Seo. See [LICENSE](LICENSE) for details.

