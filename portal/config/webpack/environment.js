const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    c3: 'c3'
  })
)

const aliasConfig = {
  'jquery': 'jquery/src/jquery',
  'jquery.nicescroll': 'jquery.nicescroll/jquery.nicescroll.js',
  'c3': 'c3/c3.js',
  'jquery-ui': 'jquery-ui-dist/jquery-ui.js'
};

environment.config.set('resolve.alias', aliasConfig);

module.exports = environment
