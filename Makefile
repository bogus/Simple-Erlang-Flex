ERL=erl
ERLC=erlc
ERLCFLAGS+=-W +debug_info
ERLS=users.erl storage_manager.erl 
BEAMS=$(ERLS:.erl=.beam)
HTTPDIR=/opt/erlang/lib/erlang/lib/http

.PHONY: clean
.SUFFIXES: .beam .erl 

all: $(BEAMS)

.erl.beam:
	$(ERLC) $(ERLCFLAGS) $<

clean:
	rm -f $(BEAMS) 

run:
	$(ERL) -pa $(HTTPDIR)/ebin $(HTTPDIR)/deps/*/ebin -s http -config bsse 
