# Changelog

## [2.1.1](https://github.com/OXY2DEV/patterns.nvim/compare/v2.1.0...v2.1.1) (2025-04-24)


### Bug Fixes

* **lua_patterns:** Fixed an issue with getting description for escaped charcaters ([e700d6c](https://github.com/OXY2DEV/patterns.nvim/commit/e700d6c2b0af402d56e0eaa9467cf487dc9fa87d))

## [2.1.0](https://github.com/OXY2DEV/patterns.nvim/compare/v2.0.0...v2.1.0) (2025-04-20)


### Features

* **regex:** Added aupport for lazy(non-greedy) version of quantifiers ([6783907](https://github.com/OXY2DEV/patterns.nvim/commit/6783907288b1cd51100615e592c8264a5231abad)), closes [#7](https://github.com/OXY2DEV/patterns.nvim/issues/7)

## [2.0.0](https://github.com/OXY2DEV/patterns.nvim/compare/v1.0.0...v2.0.0) (2025-02-20)


### ⚠ BREAKING CHANGES

* Added support for JS regexp matcher

### Features

* Added support for JS regexp matcher ([c86d755](https://github.com/OXY2DEV/patterns.nvim/commit/c86d7552a6f3a404569be8a6dc6cd2f756db5a2f)), closes [#6](https://github.com/OXY2DEV/patterns.nvim/issues/6)


### Bug Fixes

* **renderer-lua_patterns:** Fixed description of some character classes ([7b0be23](https://github.com/OXY2DEV/patterns.nvim/commit/7b0be231071a83d3ea01cc0bdeead03db9867eb8)), closes [#2](https://github.com/OXY2DEV/patterns.nvim/issues/2)

## 1.0.0 (2025-02-19)


### ⚠ BREAKING CHANGES

* Created LICENSE
* Updated README.md
* Cleaned up main file
* **core:** Initial commit

### doc

* Created LICENSE ([4905a44](https://github.com/OXY2DEV/patterns.nvim/commit/4905a44104eff2c7824d952a28293076c83bba7a))
* Updated README.md ([debb730](https://github.com/OXY2DEV/patterns.nvim/commit/debb7300b8edcdb6764946af982c7eb2d7a0180a))


### Features

* Add node type to pattern language map ([0031e20](https://github.com/OXY2DEV/patterns.nvim/commit/0031e20a2fa011c4aeaa3769017ed81fcfc76fb2))
* **core:** `patterns.hover()` Support ([83f8f42](https://github.com/OXY2DEV/patterns.nvim/commit/83f8f42496ba59e0ddb22a563c0ed2a33c7d4355))
* **core:** Added `:Patterns` user command ([534aa6e](https://github.com/OXY2DEV/patterns.nvim/commit/534aa6e0c2fddce7bdef210e69d251ca5ca282e2))
* **core:** Regex support ([42ed2d6](https://github.com/OXY2DEV/patterns.nvim/commit/42ed2d66dc6e0e928d87e6302b5908722f106a23))
* **explain:** Added apply change keymap for the explainer ([5a66d0d](https://github.com/OXY2DEV/patterns.nvim/commit/5a66d0d5b45342eaed1b08e7f9124aa6684f7242))
* **explain:** New explain command! ([c8354c5](https://github.com/OXY2DEV/patterns.nvim/commit/c8354c533058395a9ef20b6232178b1ae15b8b18))
* **renderer:** Added render clear function ([861941f](https://github.com/OXY2DEV/patterns.nvim/commit/861941f7436cb1e03eabf55df3adddf9fc4ed600))
* **renderer:** Renderer now returns the line number of the curren't nodes preview ([516286a](https://github.com/OXY2DEV/patterns.nvim/commit/516286a807b631c43136b606c47c095dd5dc98e5))


### Bug Fixes

* **core:** Fixed indentation markers overlap issues ([39ebd80](https://github.com/OXY2DEV/patterns.nvim/commit/39ebd80d6556611e5962c7640896795f74545ed9))
* **core:** Moved hover function to a separate file ([0d97df5](https://github.com/OXY2DEV/patterns.nvim/commit/0d97df590f254e1dc84bd80d30dae6e60ed053b1))
* **explain:** Added check for valid pattern for lua patterns ([5a66d0d](https://github.com/OXY2DEV/patterns.nvim/commit/5a66d0d5b45342eaed1b08e7f9124aa6684f7242))
* **explain:** Fixed ranges for the explainer ([5a66d0d](https://github.com/OXY2DEV/patterns.nvim/commit/5a66d0d5b45342eaed1b08e7f9124aa6684f7242))
* **explain:** Various improvemen ts to the explianer ([93e3c51](https://github.com/OXY2DEV/patterns.nvim/commit/93e3c5144007a35bd7fbf349e9cbe86a3490dea7))
* **hover:** Added keymap support for hover ([2e10371](https://github.com/OXY2DEV/patterns.nvim/commit/2e10371035a0cb36d9615b030a65c8355bee6acd))
* **hover:** fixed incorrect current node for hover ([10f23a5](https://github.com/OXY2DEV/patterns.nvim/commit/10f23a5540c5c60dc1b8b094e3f0a066a87a961e))
* **hover:** fixed typos ([063b165](https://github.com/OXY2DEV/patterns.nvim/commit/063b16515389b5634fbdf00e23040c91100d548e))
* **lua_patterns:** Updated node names for lua patterns ([3f76ca8](https://github.com/OXY2DEV/patterns.nvim/commit/3f76ca8c420d6933075fa46338ee44ab3f9dd5ae))
* **parser-lua_patterns:** Texts are no longer wrapped in `vim.inspect()`. ([430f94d](https://github.com/OXY2DEV/patterns.nvim/commit/430f94d3b2fd6be2f56f79d79f84eb5b93bbaf2e))
* **regex:** Added missing tips for regex ([cc17539](https://github.com/OXY2DEV/patterns.nvim/commit/cc175391efeaf5650ec8b7b8f5307ccef6e7357f))
* **renderer-regex:** More parity changes ([0fc51f3](https://github.com/OXY2DEV/patterns.nvim/commit/0fc51f3eee32f70b63f5a9f0ec3cf64976c875d7))
* **renderer-regex:** Parity changes for the regex renderer ([25f5909](https://github.com/OXY2DEV/patterns.nvim/commit/25f590917a04cf38160ac6058438d466844f7b56))
* **spec:** Fixed text for various regex node types ([c7a84b6](https://github.com/OXY2DEV/patterns.nvim/commit/c7a84b68d40dca5b284ada2edf0762c6e3a32551))
* **spec:** Moved core parts of the configuration outside ([bd74a30](https://github.com/OXY2DEV/patterns.nvim/commit/bd74a30f8f565d7f7a7adfe48366a8a348de0516))


### Miscellaneous Chores

* Cleaned up main file ([00e6be4](https://github.com/OXY2DEV/patterns.nvim/commit/00e6be4bd7e4993aae8aae7c5aca6aa5e4f9810b))


### Code Refactoring

* **core:** Initial commit ([9f651d2](https://github.com/OXY2DEV/patterns.nvim/commit/9f651d2ed5b5bafefd6c5524f5009f89e9b34b5c))
