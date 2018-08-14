# README

## Welcome to Sticker Machine!

### What is it?
This is just a fun little project to practice working with API calls in Rails and developing WeChat miniprograms. Still a WIP.

This Rails app, by itself, acts as a proxy to makes calls to the Giphy API, filters out stickers based on a few specs, then sends the results to a registered WeChat miniprogram called **StickerMachine**. 

Implementation of these specs is motivated by Chinese internet and WeChat standards. Also motivated by the fact that WeChat miniprograms will not pull in information coming from servers not based in China, hence the need for a backend at all (indeed, the original version of this project was purely a WeChat miniprogram directly calling the Giphy API.

More details on those specs below. To visit the code for the associated miniprogram, please visit https://github.com/yaycake/StickerMachine.
  
### Specs
> Filters out stickers larger than .4 MB to ensure users can save every incoming gif to their sticker collection in WeChat

> Triggers Tencent’s “message security check” aka censorship API in order to comply with Chinese standards of harmony :eyeroll:

> Filters incoming gifs by the “pg-13” parameter supplied by Giphy API, for harmony

### I want to try it!
 If you want to use StickerMachine, just enter WeChat, go to the ‘Discover’ tab, click ‘Miniprograms’ and simply search for StickerMachine!

If you want to play with the code, be our guest! Be aware that you will need to replace our credentials with:
1. Your own Giphy API key (easy) 
2. WeChat AppID and AppSecret (only easy if you’re a Chinese citizen)
3. The wx code found at the other repo mentioned above

Other things:
* Ruby 2.4.4
* Rails 5.2.1
* Gem source used in gem file is 'https://ruby.taobao.org/' - change that if you’re not in China! 
