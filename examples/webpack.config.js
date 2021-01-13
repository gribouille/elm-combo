const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')
const CopyPlugin = require('copy-webpack-plugin')
const { CleanWebpackPlugin } = require('clean-webpack-plugin')

const TITLE = 'ELM Combo Examples'
const PORT = process.env.PORT || 3000
const SERVER = process.env.SERVER || 4000
const DEST = path.resolve(__dirname, 'dist')

module.exports = {
  entry: path.resolve(__dirname, 'index.js'),
  mode: 'development',
  output: {
    path: DEST,
    filename: '[name].js',
    publicPath: ''
  },
  resolve: {
    modules: [path.resolve(__dirname, './src'), 'node_modules'],
    extensions: ['.elm', '.js', '.json']
  },
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            debug: true
          }
        }
      },
      {
        test: /\.(woff|woff2|eot|ttf|otf|svg)$/,
        loader: 'file-loader',
        options: {
          name: '[name].[ext]',
          outputPath: 'fonts/'
        }
      },
      {
        test: /\.(ts|js)x?$/,
        loader: 'babel-loader',
        exclude: /node_modules/
      },
      {
        test: /\.s[ac]ss$/i,
        use: ['style-loader', 'css-loader', 'sass-loader']
      },
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader']
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      title: TITLE,
      favicon: path.resolve(__dirname, 'favicon.ico'),
      showErrors: true,
      template: path.resolve(__dirname, 'index.ejs')
    }),
    new CleanWebpackPlugin({
      root: __dirname,
      exclude: [],
      verbose: true,
      dry: false
    }),
    new CopyPlugin({
      patterns: [
        { from: 'favicon.ico', to: DEST }
      ]
    })
  ],
  devtool: 'source-map',
  devServer: {
    disableHostCheck: true,
    historyApiFallback: true,
    host: '0.0.0.0',
    port: PORT,
    hot: true,
    contentBase: ['assets'].map(x => path.resolve(__dirname, x)),
    publicPath: '/',
    watchOptions: {
      ignored: path.resolve(__dirname, 'node_modules')
    },
    proxy: {
      '/api': {
        target: `http://0.0.0.0:${SERVER}`,
        secure: false
      }
    }
  },
  optimization: {
    splitChunks: {
      chunks: 'all'
    }
  }
}
