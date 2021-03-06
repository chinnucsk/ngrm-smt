-module(reader_worker).
-compile(export_all).

-include("../include/common.hrl").
-include("../include/db.hrl").
-include("../include/words.hrl").



-include("../include/memory.hrl").
-include("../include/processes.hrl").


start()->
    reader() ! next,
    fprof:apply(reader_worker, process_one_line, [{1, []}]).
    %process_one_line({1, []}).

reader()->
    case get(reader) of
        undefined ->
            receive
                {reader, Reader} ->
                    put(reader, Reader),
                    Reader
            after ?READER_WORKER_TIMEOUT ->
                    ?LOG("worker timed out reader() ~n", [])
            end;
        Pid ->
            Pid
    end.

process_one_line({Counter, Buffer})->
    receive
        {pair, {Data_1, Data_2, C}} ->
            case (erlang:memory(total) < ?MEMORY_LIMIT_NGRAMS_BYTES) of
                true ->
                    %io:format("true", []),
                    %Translation = sentences:times_words(Data_1, Data_2)
                    %Translation = sentences:times_sentences(Data_1, Data_2, ?NGRAM_SIZE)
                    Translation = sentences:comb_sentences(Data_1, Data_2, ?NGRAM_SIZE, ?NGRAM_DIAGONAL_OFFSET)
                    ;
                false ->
                    %io:format("false", []),
                    %Translation = sentences:times_words(Data_1, Data_2)
                    %Translation = sentences:times_sentences(Data_1, Data_2, ?NGRAM_SIZE)
                    Translation = sentences:comb_sentences(Data_1, Data_2, ?NGRAM_SIZE, ?NGRAM_DIAGONAL_OFFSET)
            end,

            %lists:foreach(fun(Pid) -> erlang:garbage_collect(Pid) end, erlang:processes() ),

            case (Counter rem ?READER_WORKER_SENTENCES_BUFFER_SIZE)of
                0 ->
                    process_buffer(Buffer),
                    New_buffer  = [Translation],
                    ?LOG("~nSave at ~p~n", [Counter]);
                _ ->
                    New_buffer = [Translation | Buffer]
            end,

            reader() ! next,

            process_one_line({Counter+1, New_buffer});
        stop ->
            process_buffer(Buffer),
            ?LOG("~nsave.~p~n", [Counter]),
            ?LOG("worker stoped~n", []),
            []
    after ?READER_WORKER_TIMEOUT ->
            ?LOG("worker timed out at process_one_line~n", []),
            []
    end.

process_buffer(Buffer)->


    case (erlang:memory(total) < ?MEMORY_LIMIT_PARALLEL_BYTES) of
        true ->
            io:format("~n(+)memory(total) ~p ~n", [erlang:memory(total) / 1024 / 1024]),
            spawn(model, train_p, [Buffer]);
        false ->
            io:format("~n(-)memory(total) ~p ~n", [erlang:memory(total) / 1024 / 1024]),
            model:train_s(Buffer)
    end.
