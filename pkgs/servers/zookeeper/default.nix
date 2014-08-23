{ stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
	name = "zookeeper-3.4.6";

	src = fetchurl {
		url = "mirror://apache/zookeeper/${name}/${name}.tar.gz";
		sha256 = "01b3938547cd620dc4c93efe07c0360411f4a66962a70500b163b59014046994";
	};

	buildInputs = [ makeWrapper jre ];

	installPhase = ''
		mkdir -p $out
		cp -R conf docs lib ${name}.jar $out
		mkdir -p $out/bin
		cp -R bin/*.sh $out/bin
		for i in $out/bin/*.sh; do
			wrapProgram $i --set JAVA_HOME "${jre}";
		done
	'';

	meta = with stdenv.lib; {
		homepage = "http://zookeeper.apache.org";
		description = "Apache Zookeeper";
		license = licenses.asl20;
		maintainers = [ maintainers.nathan-gs ];	
		platforms = platforms.unix;	
	};		

}