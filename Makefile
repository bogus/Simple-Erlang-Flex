ERL=erl
ERLC=erlc
ERLCFLAGS+=-W +debug_info
ERLS=users.erl server_util.erl storage_manager.erl
MXMLC=mxmlc
MXMLFLAGS=-services "services-config.xml"
MXMLS=main.mxml  
BEAMS=$(ERLS:.erl=.beam)
SWFS=$(MXMLS:.mxml=.swf)
HTTPDIR=/opt/erlang/lib/erlang/lib/http

.PHONY: clean
.SUFFIXES: .beam .erl .swf .mxml

all: $(BEAMS) $(SWFS)

.erl.beam:
	$(ERLC) $(ERLCFLAGS) $<

.mxml.swf:
	$(MXMLC) $(MXMLFLAGS) $<

main.swf: com/medratech/view/UsersScript.as com/medratech/bean/User.as  

clean:
	rm -f $(BEAMS) $(SWFS)

run:
	$(ERL) -pa $(HTTPDIR)/ebin $(HTTPDIR)/deps/*/ebin -s http -config users
