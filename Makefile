bootstrap: carthage_bootstrap

libxml2:
	brew install libxml2

mint: libxml2
	# mintがない場合のみインストール
	if !type mint > /dev/null 2>&1; then brew install mint; fi
	mint bootstrap

carthage_bootstrap: mint
	mint run carthage carthage bootstrap --platform ios --cache-builds
