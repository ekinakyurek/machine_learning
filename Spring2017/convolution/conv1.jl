module Ekin
    function conv1(h,x; mode=0, padding=0)

         x = reshape(x,length(x))
         h = reshape(h,length(h))

        if length(x) >= length(h)
          if mode == 0
              h = flipdim(h,1)
          end

          if padding != 0
            pad = zeros(eltype(x), padding)
            x = cat(1,pad, x, pad )
          end

          y = zeros(eltype(x), length(x)-length(h)+1)

          for i=1:length(x)-length(h)+1
            y[i] = sum(x[i:i+length(h)-1] .* h[1:length(h)])
          end

          return y;
        else
          conv1(x,h)
        end


    end

    function conv2(h,x; mode=0, padding=0)
        if ndims(h) > 1 && ndims(x) > 1

          if (ndims(h) != 2)
            h = reshape(h, (size(h,1),size(h,2)))
          end

          if (ndims(x) != 2)
            x = reshape(x, (size(x,1),size(x,2)))
          end

          if size(x,1) >= size(h,1) && size(x,2) >= size(h,2)

            if mode ==  0
                h = flipdim(h,1)
                h = flipdim(h,2)
            end

            if padding != 0

              if length(padding) == 1
                padding_size = (padding,padding)
              else
                padding_size = padding
              end

              pad1 =  zeros(eltype(x), padding_size[1], size(x,2))
              x = cat(1,pad1,x,pad1)
              pad2 =  zeros(eltype(x), size(x,1), padding_size[2])
              x = cat(2,pad2,x,pad2)

            end

            y = zeros(eltype(x), size(x,1)-size(h,1)+1,  size(x,2)-size(h,2)+1 )

            for i=1:size(x,1)-size(h,1)+1
              for j=1:size(x,2)- size(h,2) + 1
                y[i,j] = sum(x[i:i+size(h,1)-1, j:j+size(h,2)-1] .* h)
              end
            end

            return y;

          elseif size(x,1) <= size(h,1) && size(x,2) <= size(h,2)
             conv2(x,h, mode=mode, padding=padding);
          else
            println("Error:: Filter dimension exceeds the input")
            return zeros(eltype(x),size(x))
          end

      end

    end

    function conv3(h,x; mode=0, padding=0)
        if ndims(h) > 2 && ndims(x) > 2

          if (ndims(h) != 3)
            h = reshape(h, (size(h,1),size(h,2),size(h,3)))
          end

          if (ndims(x) != 3)
            x = reshape(x, (size(x,1),size(x,2), size(x,3)))
          end

          if size(x,1) >= size(h,1) && size(x,2) >= size(h,2) && size(x,3) >= size(h,3)

            if mode ==  0
                h = flipdim(h,1)
                h = flipdim(h,2)
                h = flipdim(h,3)
            end

            if padding != 0

              if length(padding) == 1
                padding_size = (padding,padding,padding)
              else
                padding_size = padding
              end

              pad1 =  zeros(eltype(x), padding_size[1], size(x,2), size(x,3))
              x = cat(1,pad1,x,pad1)
              pad2 =  zeros(eltype(x), size(x,1), padding_size[2], size(x,3))
              x = cat(2,pad2,x,pad2)
              pad3 = zeros(eltype(x), size(x,1), size(x,2), padding_size[3])
              x = cat(3,pad3,x,pad3)
            end

            y = zeros(eltype(x), size(x,1)-size(h,1)+1,  size(x,2)-size(h,2)+1 , size(x,3)-size(h,3) + 1)

            for i=1:size(x,1)-size(h,1)+1
              for j=1:size(x,2)-size(h,2) + 1
                for k=1:size(x,3)-size(h,3) + 1
                y[i,j,k] = sum(x[i:i+size(h,1)-1, j:j+size(h,2)-1, k:k+size(h,3)-1] .* h)
                end
              end
            end

           return y;

         elseif size(x,1) <= size(h,1) && size(x,2) <= size(h,2) && size(x,3) <= size(h,3)
             conv3(x,h, mode=mode, padding=padding);
          else
            println("Error:: Filter dimension exceeds the input")
            return zeros(eltype(x),size(x))
          end

      end

    end

    function conv4(h,x; mode=0, padding=0)
        if ndims(h) == 4 && ndims(x) == 4 && size(x,3) == size(h,3)
            y = zeros(eltype(x), size(x,1)-size(h,1) + 1 , size(x,2) - size(h,2) +1 , size(h,4), size(x,4))
            for i=1:size(h,4)
              for j=1:size(x,4)
                y[:,:,i,j] = reshape(conv3(h[:,:,:,i],x[:,:,:,j]), (size(y,1),size(y,2),1,1))
              end
            end
            return y;
        end
    end

end
