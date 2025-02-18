{ lib
, python3
, fetchPypi
, fetchFromGitHub
}:

let
  python = python3.override {
    # FlexGet doesn't support transmission-rpc>=5 yet
    # https://github.com/NixOS/nixpkgs/issues/258504
    packageOverrides = self: super: {
      transmission-rpc = super.transmission-rpc.overridePythonAttrs (old: rec {
        version = "4.3.1";
        src = fetchPypi {
          pname = "transmission_rpc";
          inherit version;
          hash = "sha256-Kh2eARIfM6MuXu7RjPPVhvPZ+bs0AXkA4qUCbfu5hHU=";
        };
        doCheck = false;
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "flexget";
  version = "3.9.10";
  format = "pyproject";

  # Fetch from GitHub in order to use `requirements.in`
  src = fetchFromGitHub {
    owner = "Flexget";
    repo = "Flexget";
    rev = "refs/tags/v${version}";
    hash = "sha256-cUcfXoqNKe5Ok0vDqe0uCpV84XokKe4iXbWeTm1Qv14=";
  };

  postPatch = ''
    # remove dependency constraints but keep environment constraints
    sed 's/[~<>=][^;]*//' -i requirements.txt
  '';

  nativeBuildInputs = with python.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python.pkgs; [
    # See https://github.com/Flexget/Flexget/blob/master/requirements.txt
    apscheduler
    beautifulsoup4
    click
    colorama
    commonmark
    feedparser
    guessit
    html5lib
    jinja2
    jsonschema
    loguru
    more-itertools
    packaging
    psutil
    pynzb
    pyrsistent
    pyrss2gen
    python-dateutil
    pyyaml
    rebulk
    requests
    rich
    rpyc
    sqlalchemy
    typing-extensions

    # WebUI requirements
    cherrypy
    flask-compress
    flask-cors
    flask-login
    flask-restful
    flask-restx
    flask
    pyparsing
    werkzeug
    zxcvbn

    # Plugins requirements
    transmission-rpc
  ];

  pythonImportsCheck = [
    "flexget"
    "flexget.plugins.clients.transmission"
  ];

  # ~400 failures
  doCheck = false;

  meta = with lib; {
    homepage = "https://flexget.com/";
    changelog = "https://github.com/Flexget/Flexget/releases/tag/v${version}";
    description = "Multipurpose automation tool for all of your media";
    license = licenses.mit;
    maintainers = with maintainers; [ marsam ];
  };
}
